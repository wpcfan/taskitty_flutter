import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../components/components.dart';
import '../models/models.dart';

class SelectDayPage extends StatelessWidget {
  final FirebaseAnalytics analytics;
  const SelectDayPage({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    analytics.setCurrentScreen(
      screenName: 'SelectDayPage',
      screenClassOverride: 'SelectDayPage',
    );
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final selectedDate = args['selectedDate'] as DateTime;
    final todos = args['todos'] as List<Todo>;
    return Scaffold(
        appBar: AppBar(
          title: const HorizontalTimeWidget(),
        ),
        body: TodoDayWidget(
          todos: todos,
          selectedDate: selectedDate,
        ));
  }
}
