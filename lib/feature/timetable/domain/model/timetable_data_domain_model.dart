import 'package:flutter/foundation.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';

class TimetableDataDomainModel {
  final List<TimetableEntryDomainModel> entries;
  final String? className;

  TimetableDataDomainModel({required this.entries, this.className});

  @override
  bool operator ==(Object other) =>
      other is TimetableDataDomainModel &&
      other.className == className &&
      listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hash(className, Object.hashAll(entries));
}
