import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/stats/data/repository/stats_repository_impl.dart';

void main() {
  test('statistics are available with one school period and valid grades', () {
    expect(
      canBuildStudentReport(periodsCount: 1, validGradesCount: 1),
      isTrue,
    );
  });

  test('statistics require at least one period and one valid grade', () {
    expect(
      canBuildStudentReport(periodsCount: 0, validGradesCount: 1),
      isFalse,
    );
    expect(
      canBuildStudentReport(periodsCount: 1, validGradesCount: 0),
      isFalse,
    );
  });
}
