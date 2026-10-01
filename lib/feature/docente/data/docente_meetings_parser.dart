import 'package:html/parser.dart' as html;
import 'package:registro_elettronico/feature/docente/data/docente_text.dart';

class DocenteMeeting {
  final String date;
  final String hour;
  final int parents;
  final String text;

  const DocenteMeeting(
      {required this.date,
      required this.hour,
      required this.parents,
      required this.text});

  DateTime? get day => DateTime.tryParse(date);
}

class DocenteMeetingsMonth {
  /// Months offered by the page (`td.mese[mese]`), e.g. "09" -> "Set".
  final Map<String, String> months;
  final String? selected;
  final List<DocenteMeeting> meetings;

  const DocenteMeetingsMonth(
      {required this.months, required this.selected, required this.meetings});
}

/// EXPERIMENTAL (month bar verified, slots inferred: the mapped account had
/// none). Parses the parent meetings page (`/cvv/app/default/gioprof_colloqui.php`,
/// month chosen with `?mese=MM`): the month bar and one `.jrounded-box` per
/// meeting slot, whose attributes carry date, hour and booked parents (the
/// attributes the page script reads when a slot is opened).
DocenteMeetingsMonth parseDocenteMeetings(String page) {
  final document = html.parse(page);
  final months = <String, String>{};
  String? selected;
  for (final cell in document.querySelectorAll('td.mese[mese]')) {
    final month = cell.attributes['mese']!;
    months[month] = docenteClean(cell.text);
    if (cell.classes.contains('mese_selezionato')) selected = month;
  }
  final meetings = [
    for (final box in document.querySelectorAll('.jrounded-box'))
      DocenteMeeting(
        date: box.attributes['evento_data'] ?? '',
        hour: box.attributes['ora_posizione'] ?? '',
        parents: int.tryParse(box.attributes['numero_genitori'] ?? '') ?? 0,
        text: box.children.isEmpty
            ? docenteClean(box.text)
            : box.children
                .map((c) => docenteClean(c.text))
                .where((t) => t.isNotEmpty)
                .join(' · '),
      ),
  ]..sort((a, b) => '${a.date}${a.hour}'.compareTo('${b.date}${b.hour}'));
  return DocenteMeetingsMonth(
      months: months, selected: selected, meetings: meetings);
}
