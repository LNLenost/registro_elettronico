import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/core/data/remote/web/web_spaggiari_client.dart';
import 'package:registro_elettronico/feature/authentication/domain/repository/authentication_repository.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _homeworkUrl =
    'https://web.spaggiari.eu/fml/app/default/regdidattica_studenti_compito.php';

class Homework {
  final String id;
  final String subject;
  final String teacher;
  final String instructions;
  final String period;

  const Homework({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.instructions,
    required this.period,
  });

  DateTime? get deadline {
    final match = RegExp(r'Scadenza:\s*(\d{2})/(\d{2})/(\d{4})').firstMatch(period);
    if (match == null) return null;
    return DateTime(int.parse(match.group(3)!), int.parse(match.group(2)!), int.parse(match.group(1)!));
  }

  Map<String, String> toJson() => {
        'id': id,
        'subject': subject,
        'teacher': teacher,
        'instructions': instructions,
        'period': period,
      };

  factory Homework.fromJson(Map<String, dynamic> json) => Homework(
        id: json['id'] ?? '',
        subject: json['subject'] ?? '',
        teacher: json['teacher'] ?? '',
        instructions: json['instructions'] ?? '',
        period: json['period'] ?? '',
      );
}

/// Read-only native adapter for the verified ClasseViva homework page.
class HomeworkRemoteDatasource {
  final Dio webDio;
  final WebSpaggiariClient webSpaggiariClient;
  final AuthenticationRepository authenticationRepository;
  final SharedPreferences preferences;
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  HomeworkRemoteDatasource({
    required this.webDio,
    required this.webSpaggiariClient,
    required this.authenticationRepository,
    required this.preferences,
  });

  Future<List<Homework>> getHomeworks() => refresh();

  Future<List<Homework>> refresh() async {
    final credentials = await authenticationRepository.getCredentials();
    final profile = credentials.profile;
    final password = credentials.password;
    if (profile?.ident == null || password == null) {
      throw StateError('Missing ClasseViva credentials');
    }

    final username = profile!.ident!;
    final session = await webSpaggiariClient.getPHPToken(
      username: username,
      password: password,
    );
    final response = await webDio.get<String>(
      _homeworkUrl,
      options: Options(
        headers: {
          'Cookie': '$session; weblogin=$username; LAST_REQUESTED_TARGET=cvv',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    if (response.statusCode != 200) {
      throw StateError('ClasseViva homework request was rejected');
    }
    final homeworks = parseHomeworks(response.data ?? '');
    await preferences.setString(_cacheKey, jsonEncode(homeworks.map((item) => item.toJson()).toList()));
    changes.value++;
    return homeworks;
  }

  List<Homework> getCachedHomeworks() {
    final raw = preferences.getString(_cacheKey);
    if (raw == null) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<Map>().map((item) => Homework.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  Set<String> getCompletedIds() => preferences.getStringList(_completedKey)?.toSet() ?? {};

  Future<void> toggleCompleted(String id) async {
    final completed = getCompletedIds();
    if (!completed.add(id)) completed.remove(id);
    await preferences.setStringList(_completedKey, completed.toList());
    changes.value++;
  }

  String get _accountKey => preferences.getString(PrefsConstants.databaseName) ?? PrefsConstants.defaultDbName;
  String get _cacheKey => 'homeworkCache_$_accountKey';
  String get _completedKey => 'homeworkCompleted_$_accountKey';
}

List<Homework> parseHomeworks(String page) {
  return html.parse(page).querySelectorAll('tr.compito_row').map((row) {
    final cells = row.children.where((child) => child.localName == 'td').toList();
    final teacherDetails = cells.length > 1
        ? cells[1].children.where((child) => child.localName == 'div').toList()
        : const [];
    return Homework(
      id: row.attributes['id_compito'] ?? '',
      subject: teacherDetails.isNotEmpty ? _text(teacherDetails[0]) : '',
      teacher: teacherDetails.length > 1 ? _text(teacherDetails[1]) : '',
      instructions: cells.length > 2
          ? _text(cells[2].querySelector('.istruzioni_p') ?? cells[2])
          : '',
      period: cells.length > 3 ? _text(cells[3]) : '',
    );
  }).where((homework) => homework.id.isNotEmpty).toList();
}

String _text(dynamic element) {
  final value = html.parseFragment(element.innerHtml
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' '))
      .text;
  return (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
}