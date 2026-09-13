import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/substitutions/data/myprof_api.dart';

void main() {
  test('reads the class ID accepted by the substitutions endpoint', () {
    expect(MyProfApi.idFromRecord({'id': 42}), 42);
    expect(MyProfApi.idFromRecord({'id': '7'}), 7);
    expect(MyProfApi.idFromRecord({'id': 'invalid'}), isNull);
    expect(MyProfApi.idFromRecord({}), isNull);
  });
}
