import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function(bool)? onClose;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onClose?.call(false);
          },
          child: Text(AppLocalizations.of(context)!.confirmDialogCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onClose?.call(true);
          },
          child: Text(AppLocalizations.of(context)!.confirmDialogConfirm),
        ),
      ],
    );
  }
}
