import 'package:flutter/foundation.dart';

import 'navigation_config.dart';

class HomeConfig {
  static const actions = 'actions';
  static const grades = 'grades';
  static const lessons = 'lessons';
  static const agenda = 'agenda';

  static const items = <String>[actions, grades, lessons, agenda];
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static List<String> normalizeOrder(Iterable<String>? stored) {
    return NavigationConfig.normalizeOrder(stored, known: items);
  }

  static List<String> normalizeHidden(
    Iterable<String> order,
    Iterable<String>? hidden,
  ) {
    return NavigationConfig.normalizeHidden(order, hidden, known: items);
  }

  static List<String> visibleItems(
    Iterable<String> order,
    Iterable<String>? hidden,
  ) {
    return NavigationConfig.visibleItems(order, hidden, known: items);
  }

  static void notifyChanged() => changes.value++;
}
