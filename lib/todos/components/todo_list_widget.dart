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
    return SliverList.builder(
      key: key,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItemWidget(
          key: Key('__todo_item_${todo.id}__'),
          todo: todo,
          onToggle: onToggle,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}
