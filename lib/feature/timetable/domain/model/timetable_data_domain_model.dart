import 'package:flutter/foundation.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';

class TimetableDataDomainModel {
  final List<TimetableEntryDomainModel> entries;

  TimetableDataDomainModel({required this.entries});

  @override
  bool operator ==(Object other) =>
      other is TimetableDataDomainModel && listEquals(other.entries, entries);

  @override
  int get hashCode => entries.hashCode;
}
