import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalendarWidget extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final List<dynamic> Function(DateTime)? eventLoader;
  final void Function(DateTime)? onDaySelected;
  TableCalendarWidget({
    super.key,
    this.eventLoader,
    this.onDaySelected,
    DateTime? firstDay,
    DateTime? lastDay,
  })  : firstDay = firstDay ?? DateTime.utc(2020, 12, 31),
        lastDay = lastDay ?? DateTime.utc(2050, 12, 31);

  @override
  State<TableCalendarWidget> createState() => _TableCalendarWidgetState();
}

class _TableCalendarWidgetState extends State<TableCalendarWidget> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.week: 'Week',
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = _selectedDay;
        });
        widget.onDaySelected?.call(_selectedDay);
      },
      eventLoader: widget.eventLoader,
    );
  }
}
