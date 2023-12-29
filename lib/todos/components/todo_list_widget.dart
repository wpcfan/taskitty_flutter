import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:taskitty_flutter/common/extensions/extensions.dart';

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
    todos.sort((a, b) {
      if (a.completed) {
        return 1;
      } else if (b.completed) {
        return -1;
      } else {
        return a.dueDate!.compareTo(b.dueDate!);
      }
    });
    Map<String, List<Todo>> groupedTodos = groupBy(todos, (todo) {
      if (todo.dueDate == null) {
        return 'No Due Date';
      }

      DateTime now = DateTime.now();
      DateTime dueDate = todo.dueDate!;
      int differenceInDays = dueDate.difference(now).inDays;
      if (todo.completed) {
        return 'Completed';
      } else if (differenceInDays < 0) {
        return 'Overdue';
      } else if (differenceInDays >= 7) {
        return 'Future';
      } else {
        if (dueDate.day == now.day &&
            dueDate.month == now.month &&
            dueDate.year == now.year) {
          return 'Today';
        } else if (dueDate.day == now.add(const Duration(days: 1)).day &&
            dueDate.month == now.add(const Duration(days: 1)).month &&
            dueDate.year == now.add(const Duration(days: 1)).year) {
          return 'Tomorrow';
        } else {
          return dueDate.formatted;
        }
      }
    });

    return SliverList.builder(
      key: key,
      itemCount: groupedTodos.length,
      itemBuilder: (context, index) {
        final keys = groupedTodos.keys.toList();
        final group = keys[index];
        final todosForGroup = groupedTodos[group]!;

        return [
          Text(
            group,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ).padding(all: 8.0),
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
        ].toColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
        );
      },
    );
  }
}
