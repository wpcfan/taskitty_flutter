import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/models.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final Function(Todo)? onToggle;
  final Function(Todo)? onEdit;
  final Function(Todo)? onDelete;
  final String editText;
  final String deleteText;

  const TodoItemWidget({
    super.key,
    required this.todo,
    this.onToggle,
    this.onEdit,
    this.onDelete,
    this.editText = 'Edit',
    this.deleteText = 'Delete',
  });

  @override
  Widget build(BuildContext context) {
    final completedStatus = IconButton(
      icon: Icon(
          todo.completed ? Icons.check_box : Icons.check_box_outline_blank),
      onPressed: () {
        if (onToggle != null) {
          onToggle!(todo);
        }
      },
    );

    final title = Text(
      todo.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    final description = Text(
      todo.description ?? '',
      style: const TextStyle(
        fontSize: 16,
      ),
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        description,
      ],
    );
    final row = Row(
      children: [
        completedStatus,
        Expanded(
          child: column,
        ),
      ],
    );

    final rowWithBorder = Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: row,
    );

    final editAction = SlidableAction(
      onPressed: (context) {
        if (onEdit != null) {
          onEdit!(todo);
        }
      },
      label: editText,
      backgroundColor: Colors.blue,
    );

    final deleteAction = SlidableAction(
      onPressed: (context) {
        if (onDelete != null) {
          onDelete!(todo);
        }
      },
      label: deleteText,
      backgroundColor: Colors.red,
    );

    final endActionPane = ActionPane(
      motion: const ScrollMotion(),
      children: [
        editAction,
        deleteAction,
      ],
    );

    return Slidable(
      key: const ValueKey(0),
      endActionPane: endActionPane,
      child: rowWithBorder,
    );
  }
}
