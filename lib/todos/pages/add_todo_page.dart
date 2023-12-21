import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/components.dart';

class AddTodoPage extends StatelessWidget {
  final FirebaseAnalytics analytics;
  final Function(String)? onAdd;
  const AddTodoPage({
    super.key,
    this.onAdd,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    // a text field which will display a hint when empty
    // and will display a clear button when text is entered
    final textEditingController = TextEditingController();
    final input = TextField(
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
    );
    // a icon button which will add a todo to the list
    final sendButton = ElevatedButton(
      onPressed: () {
        if (onAdd != null && textEditingController.text.isNotEmpty) {
          onAdd!.call(textEditingController.text);
          textEditingController.clear();
        }
        Navigator.pop(context);
      },
      child: Text(AppLocalizations.of(context)!.addTodoButtonText),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addTodoPageTitle),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: input,
            ),
            Expanded(
              child: SpeechToTextWidget(
                analytics: analytics,
                onVoiceRecognized: (text) {
                  textEditingController.text = text;
                  debugPrint('Voice recognized: $text');
                },
              ),
            ),
            sendButton,
          ],
        ),
      ),
    );
  }
}
