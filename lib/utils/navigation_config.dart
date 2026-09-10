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

  static List<String> normalizeOrder(
    Iterable<String>? stored, {
    List<String> known = defaultOrder,
  }) {
    final result = <String>[];
    for (final id in stored ?? const <String>[]) {
      if (known.contains(id) && !result.contains(id)) {
        result.add(id);
      }
    }
    for (final id in known) {
      if (!result.contains(id)) result.add(id);
    }
    return result;
  }

  static List<String> normalizeHidden(
    Iterable<String> order,
    Iterable<String>? hidden, {
    List<String> known = defaultOrder,
  }) {
    final normalizedOrder = normalizeOrder(order, known: known);
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
    Iterable<String>? hidden, {
    List<String> known = defaultOrder,
  }) {
    final normalizedOrder = normalizeOrder(order, known: known);
    final normalizedHidden = normalizeHidden(
      normalizedOrder,
      hidden,
      known: known,
    );
    return normalizedOrder
        .where((id) => !normalizedHidden.contains(id))
        .toList();
  }
}
