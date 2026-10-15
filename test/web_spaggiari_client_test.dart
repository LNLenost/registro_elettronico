import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/data/remote/web/web_spaggiari_client_impl.dart';

void main() {
  test('web requests have finite connection and response timeouts', () {
    final dio = createWebSpaggiariDio();

    expect(dio.options.connectTimeout, 10000);
    expect(dio.options.receiveTimeout, 15000);
  });
}
