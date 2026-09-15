import 'homework_remote_datasource.dart';

enum HomeworkFilter { all, dueSoon, expired, completed }

List<Homework> filterHomeworks(
  Iterable<Homework> homeworks,
  HomeworkFilter filter,
  DateTime now,
  Set<String> completedIds,
) {
  return homeworks.where((homework) {
    final deadline = homework.deadline;
    switch (filter) {
      case HomeworkFilter.completed:
        return completedIds.contains(homework.id);
      case HomeworkFilter.expired:
        return deadline != null && deadline.isBefore(DateTime(now.year, now.month, now.day));
      case HomeworkFilter.dueSoon:
        return deadline != null &&
            !deadline.isBefore(DateTime(now.year, now.month, now.day)) &&
            !deadline.isAfter(DateTime(now.year, now.month, now.day + 7));
      case HomeworkFilter.all:
        return true;
    }
  }).toList();
}