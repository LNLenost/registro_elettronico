import 'dart:io';

import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:registro_elettronico/core/infrastructure/error/failures.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:registro_elettronico/utils/global_utils.dart';

class ReportManager {
  static Future<void> sendEmail(
    BuildContext context, {
    Failure? failure,
  }) async {
    await FLog.exportLogs();
    final path = (await _localPath)! + "/" + PrefsConstants.DIRECTORY_NAME;
    final logFile = File('$path/flog.txt');
    if (await logFile.exists()) {
      final logs = await logFile.readAsString();
      await logFile.writeAsString(_redactLogs(logs));
    }

    final random = GlobalUtils.getRandomNumber();
    final subject = 'Bug report #$random - ${DateTime.now().toString()}';
    String userMessage = '';

    if (failure != null) {
      userMessage += failure.e.toString();
      userMessage += failure.localizedDescription(context)!;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    userMessage +=
        "Versione app: ${packageInfo.version}+${packageInfo.buildNumber}";

    userMessage += "\nPiattaforma: ${Platform.operatingSystem}\n";
    userMessage +=
        '${AppLocalizations.of(context)!.translate("email_message")}\n  -';

    final Email reportEmail = Email(
      body: userMessage,
      subject: subject,
      recipients: ['riccardocalligaro@gmail.com'],
      attachmentPaths: ['$path/flog.txt'],
      isHTML: false,
    );
    await FlutterEmailSender.send(reportEmail);
  }

  static String _redactLogs(String logs) {
    final fields = RegExp(
      r'^(.*?)(password|pass|token|cookie|authorization|z-auth-token|z-dev-apikey)\s*[:=].*$',
      caseSensitive: false,
      multiLine: true,
    );
    final bodies = RegExp(
      r'(data\s*:\s*).*$',
      caseSensitive: false,
      multiLine: true,
    );
    return logs
        .replaceAllMapped(fields, (match) => '${match.group(1)}${match.group(2)}=[REDACTED]')
        .replaceAllMapped(bodies, (match) => '${match.group(1)}[REDACTED]');
  }

  static Future<String?> get _localPath async {
    var directory;

    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }

    return directory.path;
  }
}
