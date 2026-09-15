import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/core/data/remote/web/web_spaggiari_client.dart';
import 'package:registro_elettronico/feature/authentication/domain/repository/authentication_repository.dart';

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
}

/// Read-only native adapter for the verified ClasseViva homework page.
class HomeworkRemoteDatasource {
  final Dio webDio;
  final WebSpaggiariClient webSpaggiariClient;
  final AuthenticationRepository authenticationRepository;

  HomeworkRemoteDatasource({
    required this.webDio,
    required this.webSpaggiariClient,
    required this.authenticationRepository,
  });

  Future<List<Homework>> getHomeworks() async {
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
    return parseHomeworks(response.data ?? '');
  }
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