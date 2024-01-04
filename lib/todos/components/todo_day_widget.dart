import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

import '../models/models.dart';

class TodoDayWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<Todo> todos;
  const TodoDayWidget({
    super.key,
    this.todos = const [],
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    List<TimePlannerTask> tasks = todos.map((todo) {
      return TimePlannerTask(
        dateTime: TimePlannerDateTime(
          day: 0,
          hour: todo.dueDate!.hour,
          minutes: todo.dueDate!.minute,
        ),
        minutesDuration: 60,
        child: const Text(
          'test',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
    return TimePlanner(
      startHour: 0,
      endHour: 23,
      tasks: tasks,
      headers: const [
        TimePlannerTitle(title: 'Today'),
      ],
    );
  }
}
