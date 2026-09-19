import 'package:dartz/dartz.dart';
import 'package:registro_elettronico/core/infrastructure/error/failures.dart';
import 'package:registro_elettronico/core/infrastructure/error/handler.dart';
import 'package:registro_elettronico/core/infrastructure/error/successes.dart';
import 'package:registro_elettronico/core/infrastructure/generic/resource.dart';
import 'package:registro_elettronico/feature/lessons/data/datasource/lessons_local_datasource.dart';
import 'package:registro_elettronico/feature/timetable/data/datasource/timetable_local_datasource.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_data_domain_model.dart';
import 'package:registro_elettronico/feature/timetable/domain/model/timetable_entry_domain_model.dart';
import 'package:registro_elettronico/feature/timetable/domain/repository/timetable_repository.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableLocalDatasource timetableLocalDatasource;
  final LessonsLocalDatasource lessonsLocalDatasource;

  TimetableRepositoryImpl({
    required this.timetableLocalDatasource,
    required this.lessonsLocalDatasource,
  });

  @override
  Future<Either<Failure, Success>> insertTimetableEntry({
    required TimetableEntryDomainModel entry,
  }) async {
    if (!entry.hasValidTimeRange) {
      return Left(handleError(
        '[TimetableRepository] Invalid weekly timetable entry',
        StateError('Invalid weekly timetable range'),
        StackTrace.current,
      ));
    }
    try {
      await timetableLocalDatasource.insertTimetableEntry(entry.toLocalModel());
      return Right(Success());
    } catch (e, s) {
      return Left(handleError(
        '[TimetableRepository] Error while inserting timetable entry',
        e,
        s,
      ));
    }
  }

  @override
  Future<Either<Failure, Success>> updateTimetableEntry({
    required TimetableEntryDomainModel entry,
  }) async {
    if (entry.id == null || !entry.hasValidTimeRange) {
      return Left(handleError(
        '[TimetableRepository] Invalid weekly timetable entry',
        StateError('Invalid weekly timetable range'),
        StackTrace.current,
      ));
    }
    try {
      await timetableLocalDatasource.updateTimetableEntry(entry.toLocalModel());
      return Right(Success());
    } catch (e, s) {
      return Left(handleError(
        '[TimetableRepository] Error while updating timetable entry',
        e,
        s,
      ));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteTimetableEntry({
    required int id,
  }) async {
    try {
      await timetableLocalDatasource.deleteEntryWithId(id);
      return Right(Success());
    } catch (e, s) {
      return Left(handleError(
        '[TimetableRepository] Error while deleting timetable entry',
        e,
        s,
      ));
    }
  }

  @override
  Stream<Resource<TimetableDataDomainModel>> watchTimetableData() {
    return timetableLocalDatasource.watchAllEntries().asyncMap((entries) async {
      final lessons = await lessonsLocalDatasource.getAllLessons();
      String? className;
      for (final lesson in lessons) {
        final candidate = lesson.classe?.trim();
        if (candidate != null && candidate.isNotEmpty) {
          className = candidate;
          break;
        }
      }
      return Resource.success(
        data: TimetableDataDomainModel(
          className: className,
          entries: entries
              .map((entry) => TimetableEntryDomainModel.fromLocalModel(entry))
              .toList(),
        ),
      );
    });
  }
}
