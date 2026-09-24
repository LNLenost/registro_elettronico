import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/authentication/data/datasource/didup_remote_datasource.dart';

void main() {
  test('didUP PKCE request and dashboard mapping are deterministic in shape', () {
    final client = DidUpRemoteDatasource();
    final pkce = client.createPkceRequest();
    final uri = client.authorizationUri(
      state: pkce.state,
      nonce: pkce.nonce,
      codeChallenge: pkce.challenge,
    );

    expect(uri.queryParameters['code_challenge_method'], 'S256');
    expect(pkce.verifier.length, 64);
    expect(pkce.challenge, isNotEmpty);

    final dashboard = DidUpDashboard(<String, dynamic>{
      'voti': <dynamic>[<String, dynamic>{'valore': '8'}],
      'appello': <dynamic>[<String, dynamic>{'codEvento': 'A'}],
    });
    expect(dashboard.grades, hasLength(1));
    expect(dashboard.absences, hasLength(1));
    expect(dashboard.register, isEmpty);
  });
}
