import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/utils/navigation_config.dart';

void main() {
  test('normalizes order and always keeps every known item once', () {
    expect(
      NavigationConfig.normalizeOrder(const ['grades', 'grades', 'unknown']),
      equals(const ['grades', 'home', 'agenda', 'noticeboard', 'more']),
    );
  });

  test('prevents hiding the last visible navigation item', () {
    expect(
      NavigationConfig.normalizeHidden(
        const ['home', 'grades', 'agenda', 'noticeboard', 'more'],
        const ['home', 'grades', 'agenda', 'noticeboard', 'more'],
      ),
      equals(const ['home', 'grades', 'agenda', 'noticeboard']),
    );
  });

  test('returns visible items in configured order', () {
    expect(
      NavigationConfig.visibleItems(
        const ['noticeboard', 'home', 'grades', 'agenda', 'more'],
        const ['grades', 'more'],
      ),
      equals(const ['noticeboard', 'home', 'agenda']),
    );
  });
}
