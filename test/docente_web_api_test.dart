import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/docente/data/docente_web_api.dart';

void main() {
  group('decodeDocenteResponse', () {
    test('decodes JSON served as text/html', () {
      expect(decodeDocenteResponse(200, ' [{"id":"1"}] '), [
        {'id': '1'}
      ]);
    });

    test('treats redirects and HTML pages as an expired session', () {
      expect(() => decodeDocenteResponse(302, ''),
          throwsA(isA<DocenteSessionExpired>()));
      expect(() => decodeDocenteResponse(200, '<!DOCTYPE html><html>'),
          throwsA(isA<DocenteSessionExpired>()));
      expect(() => decodeDocenteResponse(200, null),
          throwsA(isA<DocenteSessionExpired>()));
    });
  });

  test('decodeMixedUtf8 keeps UTF-8 and recovers Latin-1 bytes', () {
    // "1° Periodo" in Latin-1, then "Nicolò" in UTF-8, then "½" in Latin-1.
    final bytes = <int>[
      0x31,
      0xB0,
      0x20,
      ...'Periodo '.codeUnits,
      ...utf8.encode('Nicolò'),
      0x20,
      0xBD,
      0x80
    ];
    expect(decodeMixedUtf8(bytes), '1° Periodo Nicolò ½€');
  });

  test('isDocenteLoginPage recognises the login page only', () {
    expect(
        isDocenteLoginPage('<html><head><title>Login CVV Classeviva</title>'),
        isTrue);
    expect(isDocenteLoginPage('<html><head><title>Le mie classi</title>'),
        isFalse);
  });

  test('formatAgendaBound matches the web agenda format', () {
    final value = formatAgendaBound(DateTime(2026, 9, 28));
    expect(value, matches(RegExp(r'^2026-09-28T00:00:00[+-]\d{2}:\d{2}$')));
  });

  test('mobileUserAgent marks large-screen WebViews as phones', () {
    const tablet =
        'Mozilla/5.0 (Linux; Android 17; SM-F971B; wv) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Version/4.0 Chrome/153.0 Safari/537.36';
    expect(
        mobileUserAgent(tablet), contains('Chrome/153.0 Mobile Safari/537.36'));
    final phone = mobileUserAgent(tablet);
    expect(mobileUserAgent(phone), phone);
  });

  test('isCieIdEntry matches only the CIE entry pages', () {
    bool entry(String url) => isCieIdEntry(Uri.parse(url));
    const idp = 'https://idserver.servizicie.interno.gov.it/idp/login';
    expect(entry('$idp/livello2?opId=x&value=e1s2'), isTrue);
    expect(entry('$idp/livello2mobile?value=e1s2'), isFalse);
    expect(entry('$idp/livello1e2postqrcode'), isFalse);
    expect(entry('https://web.spaggiari.eu/idp/login/livello2'), isFalse);
  });

  test('isCieIdIosEntry follows the IPZS iOS SDK', () {
    bool entry(String url) => isCieIdIosEntry(Uri.parse(url));
    const cie = 'https://idserver.servizicie.interno.gov.it/idp/login';
    const ios = 'https://ios.idserver.servizicie.interno.gov.it';
    expect(entry('$cie/livello2?opId=x'), isTrue);
    expect(entry('$cie/livello1?opId=x'), isTrue);
    expect(entry('$ios/idp/login/livello2?value=x'), isTrue);
    expect(entry('$ios/idp/x?nextUrl=https%3A%2F%2Fa.it'), isTrue);
    expect(entry('$cie/livello2mobile?value=x'), isFalse);
    expect(entry('$cie/livello1e2postqrcode'), isFalse);
    expect(entry('https://idserver.servizicie.interno.gov.it/x?nextUrl=a'),
        isFalse);
    expect(entry('https://web.spaggiari.eu/idp/login/livello2'), isFalse);
    expect(entry('https://evil.it/idp/login/livello2'), isFalse);
  });

  test('redactUrl keeps parameter names only', () {
    expect(redactUrl('https://a.it/p?code=secret&state=s'),
        'https://a.it/p?[code,state]');
    expect(redactUrl(''), '');
  });

  test('sessionIdFromCookieHeader extracts PHPSESSID', () {
    expect(
        sessionIdFromCookieHeader(
            'LAST_REQUESTED_TARGET=cvv; PHPSESSID=abc123; x=y'),
        'abc123');
    expect(sessionIdFromCookieHeader('PHPSESSID='), isNull);
    expect(sessionIdFromCookieHeader(null), isNull);
  });

  test('parseProfiles handles the double-encoded evaluateJavascript result',
      () {
    final profiles = jsonEncode(jsonEncode([
      {'userType': 'A', 'ruolo': 'Docente'},
      {'userType': 'S', 'ruolo': 'Studente'},
    ]));
    final parsed = parseProfiles(profiles);
    expect(parsed.map((p) => p.isTeacher), [true, false]);
    expect(parsed.first.role, 'Docente');
  });

  test('agenda events and notices parse the web payloads', () {
    final event = DocenteAgendaEvent.fromJson({
      'id': '9',
      'allDay': false,
      'start': '2026-09-28 12:00:00',
      'end': '2026-09-28 13:00:00',
      'classe_desc': '3A',
      'materia_desc': 'FISICA',
      'tipologia': 'Lezione',
      'title': 'Lezione',
      'nota': null,
    });
    expect(event.start, DateTime(2026, 9, 28, 12));
    expect(event.note, '');

    final notices = DocenteNotices.fromJson({
      'msg_new': [
        {
          'id': '1',
          'codice': 5,
          'titolo': 'Circ. 1',
          'data_start': '2026-09-28',
          'conf_lettura': 'non_letto'
        }
      ],
      'read': [
        {
          'id': '2',
          'codice': 6,
          'titolo': 'Circ. 2',
          'data_start': '2026-09-20',
          'conf_lettura': 'letto'
        }
      ],
    });
    expect(notices.unread.single.read, isFalse);
    expect(notices.read.single.read, isTrue);
    expect(notices.unread.single.publishedOn, DateTime(2026, 9, 28));
  });
}
