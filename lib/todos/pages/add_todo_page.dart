import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskitty_flutter/todos/todos.dart';
import 'package:uuid/uuid.dart';

import '../../common/common.dart';

class AddTodoPage extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const AddTodoPage({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    // a text field which will display a hint when empty
    // and will display a clear button when text is entered
    final textEditingController = TextEditingController();

    return Scaffold(
      appBar: buildAppBar(context),
      body: buildScaffoldBody(textEditingController, context),
    );
  }

  Widget buildScaffoldBody(
      TextEditingController textEditingController, BuildContext context) {
    return [
      buildInput(textEditingController, context),
      buildSpeechToText(textEditingController),
      buildConfirm(textEditingController, context),
    ]
        .toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
        )
        .safeArea();
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.addTodoPageTitle),
    );
  }

  Widget buildSpeechToText(TextEditingController textEditingController) {
    return SpeechToTextWidget(
      analytics: analytics,
      onVoiceRecognized: (text) {
        textEditingController.text = text;
        debugPrint('Voice recognized: $text');
      },
    ).expanded();
  }

  ElevatedButton buildConfirm(
      TextEditingController textEditingController, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (textEditingController.text.trim().isNotEmpty) {
          final todo = Todo(
            id: const Uuid().v4(),
            title: textEditingController.text,
          );

          textEditingController.clear();
          Navigator.pop(context, todo);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.addTodoErrorTextIsEmpty),
            ),
          );
        }
      },
      child: Text(AppLocalizations.of(context)!.addTodoButtonText),
    );
  }

  Widget buildInput(
      TextEditingController textEditingController, BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.addTodoHintText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            textEditingController.clear();
          },
        ),
      ),
    ).padding(all: 16);
  }
}
