class NavigationConfig {
  static const home = 'home';
  static const grades = 'grades';
  static const agenda = 'agenda';
  static const noticeboard = 'noticeboard';
  static const more = 'more';

  static const defaultOrder = <String>[
    home,
    grades,
    agenda,
    noticeboard,
    more,
  ];

  static List<String> normalizeOrder(Iterable<String>? stored) {
    final result = <String>[];
    for (final id in stored ?? const <String>[]) {
      if (defaultOrder.contains(id) && !result.contains(id)) {
        result.add(id);
      }
    }
    for (final id in defaultOrder) {
      if (!result.contains(id)) result.add(id);
    }
    return result;
  }

  static List<String> normalizeHidden(
    Iterable<String> order,
    Iterable<String>? hidden,
  ) {
    final normalizedOrder = normalizeOrder(order);
    final result = <String>[];
    for (final id in hidden ?? const <String>[]) {
      if (normalizedOrder.contains(id) && !result.contains(id)) {
        result.add(id);
      }
    }
    if (result.length == normalizedOrder.length) {
      result.remove(normalizedOrder.last);
    }
    return result;
  }

  static List<String> visibleItems(
    Iterable<String> order,
    Iterable<String>? hidden,
  ) {
    final normalizedOrder = normalizeOrder(order);
    final normalizedHidden = normalizeHidden(normalizedOrder, hidden);
    return normalizedOrder
        .where((id) => !normalizedHidden.contains(id))
        .toList();
  }
}
