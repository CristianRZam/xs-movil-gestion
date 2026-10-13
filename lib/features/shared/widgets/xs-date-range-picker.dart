import 'package:flutter/material.dart';

/// Selector reutilizable de rangos que evita la edición manual de fechas.
class XsDateRangePicker extends StatelessWidget {
  const XsDateRangePicker({
    super.key,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.labelText = 'Rango de fechas',
    this.enabled = true,
    this.icon = Icons.date_range_outlined,
  });

  final DateTimeRange value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTimeRange> onChanged;
  final String labelText;
  final bool enabled;
  final IconData icon;

  Future<void> _selectRange(BuildContext context) async {
    if (!enabled) return;

    final selected = await showDateRangePicker(
      context: context,
      firstDate: _dateOnly(firstDate),
      lastDate: _dateOnly(lastDate),
      initialDateRange: DateTimeRange(
        start: _dateOnly(value.start),
        end: _dateOnly(value.end),
      ),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (selected != null) onChanged(selected);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final rangeLabel = '${localizations.formatMediumDate(value.start)} – '
        '${localizations.formatMediumDate(value.end)}';

    return Semantics(
      button: true,
      label: labelText,
      value: rangeLabel,
      child: OutlinedButton.icon(
        onPressed: enabled ? () => _selectRange(context) : null,
        icon: Icon(icon),
        label: Text(rangeLabel),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
