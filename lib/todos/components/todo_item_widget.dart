import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:relative_time/relative_time.dart';

import '../../common/common.dart';
import '../models/models.dart';

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final Function(Todo)? onToggle;
  final Function(Todo)? onEdit;
  final Function(Todo)? onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    this.onToggle,
    this.onEdit,
    this.onDelete,
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
      todo.title ?? '',
      style: titleStyle,
    );

    final tags = (todo.tags ?? [])
        .map((e) => Chip(label: Text(e)))
        .toList()
        .toRow(separator: const SizedBox(width: 5));

    final updated = Text(
      todo.updatedAt.relativeTime(context),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );

    final bottomRow = [
      tags,
      updated,
    ].toRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );

    final column = [
      title,
      bottomRow,
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    final row = [
      completedStatus,
      column.expanded(),
    ].toRow(
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    final rowWithBorder = row
        .padding(
          all: 10,
        )
        .decorated(
          border: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
        )
        .inkWell(
      onTap: () {
        if (onEdit != null) {
          onEdit!(todo);
        }
      },
    );

    final deleteAction = SlidableAction(
      onPressed: (context) {
        if (onDelete != null) {
          // pop up a dialog to confirm delete
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmDialog(
                title: AppLocalizations.of(context)!.confirmDeleteTitle,
                content: AppLocalizations.of(context)!.confirmDeleteContent,
                onClose: (result) {
                  if (result) {
                    onDelete!(todo);
                  }
                },
              );
            },
          );
        }
      },
      label: AppLocalizations.of(context)!.slidableActionDelete,
      backgroundColor: Colors.red,
    );

    final endActionPane = ActionPane(
      motion: const ScrollMotion(),
      children: [
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
