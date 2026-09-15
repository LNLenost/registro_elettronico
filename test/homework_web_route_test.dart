import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/utils/constants/registro_constants.dart';

void main() {
  test('uses the verified ClasseViva homework page', () {
    expect(
      RegistroConstants.CLASSEVIVA_HOMEWORK,
      'https://web.spaggiari.eu/fml/app/default/regdidattica_studenti_compito.php',
    );
  });
}