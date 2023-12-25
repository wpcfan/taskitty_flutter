import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:relative_time/relative_time.dart';

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

    final titleStyle = todo.completed
        ? const TextStyle(
            fontSize: 16,
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          )
        : const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          );

    final title = Text(
      todo.title,
      style: titleStyle,
    );

    final description = Text(
      todo.description ?? '',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    );

    final updated = Text(
      todo.updatedAt.relativeTime(context),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );

    final bottomRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        description,
        updated,
      ],
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        bottomRow,
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
          // pop up a dialog to confirm delete
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete Todo'),
                content: const Text('Are you sure you want to delete this?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete!(todo);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
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
