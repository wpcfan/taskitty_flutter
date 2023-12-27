import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskitty_flutter/todos/todos.dart';
import 'package:uuid/uuid.dart';

import '../../common/common.dart';

class AddTodoPage extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final List<String> topTags;
  const AddTodoPage({
    super.key,
    required this.analytics,
    this.topTags = const [],
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  late List<String> _tags;
  late TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _tags = [];
    widget.analytics.setCurrentScreen(
      screenName: 'AddTodoPage',
      screenClassOverride: 'AddTodoPage',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildScaffoldBody(context),
    );
  }

  Widget buildScaffoldBody(BuildContext context) {
    return [
      buildInput(context),
      buildSpeechToText(),
      buildTags(),
      const Spacer(),
      buildConfirm(context),
    ]
        .toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
        )
        .safeArea();
  }

  Widget buildTags() {
    return TagsWidget(
      topTags: widget.topTags,
      onTagChanged: (tags) {
        setState(() {
          _tags = tags;
        });
        debugPrint('Tags changed: $tags');
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.addTodoPageTitle),
    );
  }

  Widget buildSpeechToText() {
    return SpeechToTextWidget(
      analytics: widget.analytics,
      onVoiceRecognized: (text) {
        _textEditingController.text = text;
        debugPrint('Voice recognized: $text');
      },
    );
  }

  ElevatedButton buildConfirm(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_textEditingController.text.trim().isNotEmpty) {
          setState(() {
            final todo = Todo(
              id: const Uuid().v4(),
              title: _textEditingController.text.trim(),
              tags: _tags,
            );
            _textEditingController.clear();
            Navigator.pop(context, todo);
          });
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

  Widget buildInput(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.addTodoHintText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _textEditingController.clear();
          },
        ),
      ),
    ).padding(all: 16);
  }
}
