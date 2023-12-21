import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskitty_flutter/todos/todos.dart';
import 'package:uuid/uuid.dart';

import '../blocs/blocs.dart';

class AddTodoPage extends StatelessWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  const AddTodoPage({
    super.key,
    required this.analytics,
    required this.auth,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    // a text field which will display a hint when empty
    // and will display a clear button when text is entered
    final textEditingController = TextEditingController();

    return BlocProvider<TodoBloc>(
      create: (context) => TodoBloc(
        auth: auth,
        firestore: firestore,
      ),
      child: BlocConsumer<TodoBloc, TodoState>(
        listener: listenStateChange,
        builder: (context, state) {
          return Scaffold(
            appBar: buildAppBar(context),
            body: buildScaffoldBody(textEditingController, context),
          );
        },
      ),
    );
  }

  SafeArea buildScaffoldBody(
      TextEditingController textEditingController, BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildInput(textEditingController, context),
          buildSpeechToText(textEditingController),
          buildConfirm(textEditingController, context),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.addTodoPageTitle),
    );
  }

  Expanded buildSpeechToText(TextEditingController textEditingController) {
    return Expanded(
      child: SpeechToTextWidget(
        analytics: analytics,
        onVoiceRecognized: (text) {
          textEditingController.text = text;
          debugPrint('Voice recognized: $text');
        },
      ),
    );
  }

  ElevatedButton buildConfirm(
      TextEditingController textEditingController, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (textEditingController.text.isNotEmpty) {
          context.read<TodoBloc>().add(AddTodo(Todo(
                id: const Uuid().v4(),
                title: textEditingController.text,
              )));
          textEditingController.clear();
        }
        Navigator.pop(context);
      },
      child: Text(AppLocalizations.of(context)!.addTodoButtonText),
    );
  }

  Padding buildInput(
      TextEditingController textEditingController, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
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
      ),
    );
  }

  void listenStateChange(context, state) {
    if (state is TodoError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    }
  }
}
