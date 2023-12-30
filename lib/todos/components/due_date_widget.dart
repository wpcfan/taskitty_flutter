import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DueDateWidget extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final IconData calendarIcon;
  final String dateFormat;
  final Function(String)? onDateChanged;
  final Function()? onDateNotSelected;

  const DueDateWidget({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.calendarIcon = Icons.calendar_today,
    this.dateFormat = 'yyyy-MM-dd',
    this.onDateChanged,
    this.onDateNotSelected,
  });

  @override
  State<DueDateWidget> createState() => _DueDateWidgetState();
}

class _DueDateWidgetState extends State<DueDateWidget> {
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    dateController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: dateController,
      decoration: InputDecoration(
        icon: Icon(widget.calendarIcon),
        labelText: AppLocalizations.of(context)!.dueDateHint,
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.initialDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );

        if (pickedDate != null) {
          String formattedDate =
              DateFormat(widget.dateFormat).format(pickedDate);

          setState(() {
            dateController.text = formattedDate;
          });

          if (widget.onDateChanged != null) {
            widget.onDateChanged!(formattedDate);
          }
        } else {
          if (widget.onDateNotSelected != null) {
            widget.onDateNotSelected!();
          }
        }
      },
    );
  }
}
