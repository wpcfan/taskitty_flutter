import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/blocs.dart';
import '../components/components.dart';
import '../models/models.dart';

class SelectDayPage extends StatelessWidget {
  final List<Todo> todos;
  final DateTime selectedDate;
  const SelectDayPage({
    super.key,
    required this.selectedDate,
    this.todos = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
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
    });
  }
}
