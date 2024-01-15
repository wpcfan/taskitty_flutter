import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskitty_flutter/todos/todos.dart';
import 'package:uuid/uuid.dart';

import '../../blocs/blocs.dart';
import '../../common/common.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({
    super.key,
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  late List<String> _tags;
  late TextEditingController _textEditingController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _tags = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(
        analytics: context.read<FirebaseAnalytics>(),
      ),
      child: Builder(builder: (context) {
        final analyticsBloc = context.read<AnalyticsBloc>();
        analyticsBloc.add(AnalyticsEventPageView(
          screenName: 'AddTodoPage',
          screenClassOverride: 'AddTodoPage',
        ));
        return Scaffold(
          appBar: buildAppBar(context),
          body: buildScaffoldBody(context),
        );
      }),
    );
  }

  Widget buildScaffoldBody(BuildContext context) {
    final topTags = ModalRoute.of(context)?.settings.arguments as List<String>?;
    return [
      buildInput(context).expanded(),
      buildSpeechToText().expanded(),
      buildTags(topTags ?? []).expanded(),
      buildDueDate().expanded(),
      buildConfirm(context),
    ]
        .toColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
        )
        .constrained(maxHeight: 600)
        .scrollable(
          padding: const EdgeInsets.all(16),
        )
        .safeArea();
  }

  Widget buildTags(List<String> topTags) {
    onTagChanged(tags) {
      setState(() {
        _tags = tags;
      });
      debugPrint('Tags changed: $tags');
    }

    return TagsWidget(
      topTags: topTags,
      onTagChanged: onTagChanged,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.addTodoPageTitle),
    );
  }

  Widget buildDueDate() {
    final now = DateTime.now();
    onDateChanged(date) {
      setState(() {
        _dueDate = DateTime.parse(date);
      });
    }

    onDateNotSelected() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.addTodoErrorDueDateNotSelected,
          ),
        ),
      );
    }

    return DueDateWidget(
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      onDateChanged: onDateChanged,
      onDateNotSelected: onDateNotSelected,
    );
  }

  Widget buildSpeechToText() {
    return SpeechToTextWidget(
      onVoiceRecognized: (text) {
        _textEditingController.text = text;
        debugPrint('Voice recognized: $text');
      },
    );
  }

  ElevatedButton buildConfirm(BuildContext context) {
    onPressedConfirm() {
      if (_textEditingController.text.trim().isNotEmpty) {
        setState(() {
          final todo = Todo(
            id: const Uuid().v4(),
            title: _textEditingController.text.trim(),
            tags: _tags,
            dueDate: _dueDate,
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
    }

    return ElevatedButton(
      onPressed: onPressedConfirm,
      child: Text(AppLocalizations.of(context)!.addTodoButtonText),
    );
  }

  Widget buildInput(BuildContext context) {
    var iconButton = IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        _textEditingController.clear();
      },
    );
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.addTodoHintText,
        suffixIcon: iconButton,
      ),
    );
  }
}
