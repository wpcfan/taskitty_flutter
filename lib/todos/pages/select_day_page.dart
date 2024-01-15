import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/blocs.dart';
import '../components/components.dart';
import '../models/models.dart';

class SelectDayPage extends StatelessWidget {
  const SelectDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final selectedDate = args['selectedDate'] as DateTime;
    final todos = args['todos'] as List<Todo>;

    return BlocProvider(
      create: (context) => AnalyticsBloc(
        analytics: context.read<FirebaseAnalytics>(),
      ),
      child: Builder(builder: (context) {
        final analyticsBloc = context.read<AnalyticsBloc>();
        analyticsBloc.add(AnalyticsEventPageView(
          screenName: 'SelectDayPage',
          screenClassOverride: 'SelectDayPage',
        ));
        return Scaffold(
            appBar: AppBar(
              title: const HorizontalTimeWidget(),
            ),
            body: TodoDayWidget(
              todos: todos,
              selectedDate: selectedDate,
            ));
      }),
    );
  }
}
