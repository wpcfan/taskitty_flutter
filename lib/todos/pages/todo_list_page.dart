import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:taskitty_flutter/common/common.dart';

import '../blocs/blocs.dart';
import '../components/components.dart';
import '../models/models.dart';

class TodoListPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseAnalytics analytics;
  final DeviceCalendarPlugin deviceCalendarPlugin;
  const TodoListPage({
    super.key,
    required this.firestore,
    required this.auth,
    required this.analytics,
    required this.deviceCalendarPlugin,
  });

  @override
  Widget build(BuildContext context) {
    analytics.setCurrentScreen(
      screenName: 'TodoListPage',
      screenClassOverride: 'TodoListPage',
    );
    return BlocProvider<TodoBloc>(
      create: (context) => TodoBloc(
        firestore: firestore,
        auth: auth,
        deviceCalendarPlugin: deviceCalendarPlugin,
      )..add(const LoadTodos()),
      child: Builder(builder: (context) {
        return BlocConsumer<TodoBloc, TodoState>(
          listener: listenStateChanges,
          buildWhen: (previous, current) =>
              previous != current && current.error.isEmpty,
          builder: (context, state) => _buildBody(context, state),
        );
      }),
    );
  }

  void listenStateChanges(context, state) {
    if (state.error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error),
        ),
      );

      context.read<TodoBloc>().add(const ClearError());
    }

    if (state.updating) {
      EasyLoading.show(status: 'Updating...');
    } else {
      EasyLoading.dismiss();
    }
  }

  Widget _buildBody(BuildContext context, TodoState state) {
    final bloc = context.read<TodoBloc>();
    final todoList = TodoListWidget(
      todos: state.filteredTodos,
      onToggle: (todo) {
        context.read<TodoBloc>().add(ToggleTodo(todo));
      },
      onDelete: (todo) {
        context.read<TodoBloc>().add(DeleteTodo(todo.id ?? ''));
      },
    );

    final calendar = TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.week,
      onDaySelected: (selectedDay, focusedDay) {
        bloc.add(SelectDay(selectedDay));
      },
      eventLoader: (day) {
        final todos = state.todos.where((todo) {
          return todo.dueDate?.day == day.day &&
              todo.dueDate?.month == day.month &&
              todo.dueDate?.year == day.year;
        }).toList();

        return todos;
      },
    );

    const decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue,
          Colors.green,
        ],
      ),
    );
    final sliver = state.loading && state.todos.isEmpty
        ? const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : [calendar.toSliver().sliverPadding(all: 10), todoList]
            .toMultiSliver();
    return Scaffold(
      body: MyCustomScrollView(
        decoration: decoration,
        sliverAppBar: MySliverAppBar(
          decoration: decoration,
          onRightIconTap: () async {
            final topTags = state.topTags;
            final todo = await Navigator.of(context)
                .pushNamed('/add_todo', arguments: topTags);
            if (todo != null) {
              bloc.add(AddTodo(todo as Todo));
            }
          },
          onChanged: (value) {
            bloc.add(SearchTodos(value));
          },
        ),
        sliver: sliver,
        onRefresh: () async {
          bloc.add(const LoadTodos());
          await bloc.stream.firstWhere((state) => !state.loading);
        },
      ),
    );
  }
}
