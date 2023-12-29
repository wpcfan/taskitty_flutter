import 'package:flutter/material.dart';

import '../models/models.dart';
import 'todo_item_widget.dart';

class TodoListWidget extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo)? onToggle;
  final Function(Todo)? onEdit;
  final Function(Todo)? onDelete;

  const TodoListWidget({
    super.key,
    this.todos = const [],
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, List<Todo>> groupedTodos = {};

    // Group todos by weekday
    for (var todo in todos) {
      if (todo.dueDate == null) {
        continue;
      }

      DateTime now = DateTime.now();
      DateTime dueDate = todo.dueDate!;
      int differenceInDays = dueDate.difference(now).inDays;

      if (differenceInDays < 0) {
        // Overdue group
        if (!groupedTodos.containsKey('Overdue')) {
          groupedTodos['Overdue'] = [];
        }
        groupedTodos['Overdue']!.add(todo);
      } else if (differenceInDays >= 7) {
        // Future group
        if (!groupedTodos.containsKey('Future')) {
          groupedTodos['Future'] = [];
        }
        groupedTodos['Future']!.add(todo);
      } else {
        // Group by weekday
        String weekday = dueDate.weekday.toString();
        if (!groupedTodos.containsKey(weekday)) {
          groupedTodos[weekday] = [];
        }
        groupedTodos[weekday]!.add(todo);
      }
    }

    return SliverList.builder(
      key: key,
      itemCount: groupedTodos.length,
      itemBuilder: (context, index) {
        final keys = groupedTodos.keys.toList();
        final group = keys[index];
        final todosForGroup = groupedTodos[group]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _getGroupName(group),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todosForGroup.length,
              itemBuilder: (context, index) {
                final todo = todosForGroup[index];
                return TodoItemWidget(
                  key: Key('__todo_item_${todo.id}__'),
                  todo: todo,
                  onToggle: onToggle,
                  onEdit: onEdit,
                  onDelete: onDelete,
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getGroupName(String group) {
    switch (group) {
      case '1':
        return 'Monday';
      case '2':
        return 'Tuesday';
      case '3':
        return 'Wednesday';
      case '4':
        return 'Thursday';
      case '5':
        return 'Friday';
      case '6':
        return 'Saturday';
      case '7':
        return 'Sunday';
      case 'Overdue':
        return 'Overdue';
      case 'Future':
        return 'Future';
      default:
        return '';
    }
  }
}
