import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/data/local/moor_database.dart';
import 'package:registro_elettronico/feature/absences/presentation/absences_list.dart';

Absence _absence(int id, DateTime date) => Absence(
      evtId: id,
      evtCode: 'ABA0',
      evtDate: date,
      evtHPos: null,
      evtValue: null,
      isJustified: false,
      justifiedReasonCode: null,
      justifReasonDesc: null,
    );

void main() {
  test('date filter includes both range boundaries', () {
    final absences = <Absence>[
      _absence(1, DateTime(2026, 1, 31, 23, 59)),
      _absence(2, DateTime(2026, 2, 1)),
      _absence(3, DateTime(2026, 2, 15, 12)),
      _absence(4, DateTime(2026, 2, 16)),
    ];

    final filtered = filterAbsencesByDateRange(
      absences,
      DateTimeRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 15),
      ),
    );

    expect(filtered.map((absence) => absence.evtId), [2, 3]);
  });

  test('date filter preserves the original list when disabled', () {
    final absences = <Absence>[_absence(1, DateTime(2026, 2, 1))];

    expect(filterAbsencesByDateRange(absences, null), same(absences));
  });
}
