import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/utils/home_config.dart';

void main() {
  test('normalizes home sections and appends missing sections', () {
    expect(
      HomeConfig.normalizeOrder(const ['agenda', 'agenda', 'unknown']),
      equals(const ['agenda', 'actions', 'grades', 'lessons', 'homework']),
    );
  });

  test('keeps one home section visible when all are hidden', () {
    expect(
      HomeConfig.normalizeHidden(
        const ['actions', 'grades', 'lessons', 'agenda', 'homework'],
        const ['actions', 'grades', 'lessons', 'agenda', 'homework'],
      ),
      equals(const ['actions', 'grades', 'lessons', 'agenda']),
    );
  });

  test('returns home sections in configured visible order', () {
    expect(
      HomeConfig.visibleItems(
        const ['agenda', 'actions', 'grades', 'lessons', 'homework'],
        const ['grades'],
      ),
      equals(const ['agenda', 'actions', 'lessons', 'homework']),
    );
  });
}
