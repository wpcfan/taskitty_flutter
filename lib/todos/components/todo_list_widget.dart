import 'package:flutter/material.dart';

import '../models/models.dart';
import 'todo_item_widget.dart';

class TodoListWidget extends StatelessWidget {
  final List<Todo> todos;
  const TodoListWidget({super.key, this.todos = const []});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItemWidget(
          key: Key('__todo_item_${todo.id}'),
          todo: todo,
        );
      },
    );
  }
}
