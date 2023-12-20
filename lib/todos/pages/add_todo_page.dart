import 'package:flutter/material.dart';

import '../components/components.dart';

class AddTodoPage extends StatelessWidget {
  final Function(String)? onAdd;
  const AddTodoPage({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // a text field which will display a hint when empty
    // and will display a clear button when text is entered
    final textEditingController = TextEditingController();
    final input = TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: 'What needs to be done?',
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
      child: const Text('Confirm'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Expanded(child: input),
            ),
            Expanded(
              child: SpeechToTextWidget(onVoiceRecognized: (text) {
                textEditingController.text = text;
                debugPrint('Voice recognized: $text');
              }),
            ),
            sendButton,
          ],
        ),
      ),
    );
  }
}
