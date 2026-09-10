class NotificationDiff {
  static List<T> newItems<T, K>(
    Iterable<T> before,
    Iterable<T> after,
    K Function(T item) key,
  ) {
    final known = before.map(key).toSet();
    return after.where((item) => !known.contains(key(item))).toList();
  }
}
