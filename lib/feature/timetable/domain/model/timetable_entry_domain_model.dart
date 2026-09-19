import 'dart:convert';

import 'package:registro_elettronico/core/data/local/moor_database.dart';

class TimetableEntryDomainModel {
  int? id;
  int? start;
  int? end;
  int? dayOfWeek;
  int? subject;
  String? subjectName;

  TimetableEntryDomainModel({
    required this.id,
    required this.start,
    required this.end,
    required this.dayOfWeek,
    required this.subject,
    required this.subjectName,
  });

  factory TimetableEntryDomainModel.manual({
    required int? id,
    required int dayOfWeek,
    required String subjectName,
    required int startMinutes,
    required int endMinutes,
  }) =>
      TimetableEntryDomainModel(
        id: id,
        start: startMinutes,
        end: endMinutes,
        dayOfWeek: dayOfWeek,
        subject: null,
        subjectName: subjectName,
      );

  // ponytail: pre-existing rows stored relative hours; minute values are new.
  int get startMinutes => (start ?? 0) >= 420 ? start! : ((start ?? 0) + 7) * 60;
  int get endMinutes => (end ?? 0) >= 480 ? end! : ((end ?? 0) + 8) * 60;
  bool get hasValidTimeRange =>
      dayOfWeek != null && dayOfWeek! >= 0 && dayOfWeek! < 6 &&
      subjectName != null && subjectName!.trim().isNotEmpty &&
      startMinutes >= 0 && endMinutes <= 1440 && endMinutes > startMinutes;

  TimetableEntryDomainModel.fromLocalModel(TimetableEntryLocalModel l)
      : id = l.id, start = l.start, end = l.end, dayOfWeek = l.dayOfWeek,
        subject = l.subject, subjectName = l.subjectName;

  TimetableEntryLocalModel toLocalModel() => TimetableEntryLocalModel(
    id: id, start: start, end: end, dayOfWeek: dayOfWeek,
    subject: subject, subjectName: subjectName,
  );

  Map<String, dynamic> toMap() => {'id': id, 'start': start, 'end': end, 'dayOfWeek': dayOfWeek, 'subject': subject, 'subjectName': subjectName};
  static TimetableEntryDomainModel? fromMap(Map<String, dynamic>? map) => map == null ? null : TimetableEntryDomainModel(id: map['id'], start: map['start'], end: map['end'], dayOfWeek: map['dayOfWeek'], subject: map['subject'], subjectName: map['subjectName']);
  String toJson() => json.encode(toMap());
  static TimetableEntryDomainModel? fromJson(String source) => TimetableEntryDomainModel.fromMap(json.decode(source));
}
