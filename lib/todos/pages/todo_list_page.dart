import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskitty_flutter/common/common.dart';

import '../../blocs/blocs.dart';
import '../blocs/blocs.dart';
import '../components/components.dart';
import '../models/models.dart';

class TodoListPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final DeviceCalendarPlugin deviceCalendarPlugin;
  const TodoListPage({
    super.key,
    required this.firestore,
    required this.auth,
    required this.deviceCalendarPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TodoBloc>(
          create: (context) => TodoBloc(
            firestore: firestore,
            auth: auth,
            deviceCalendarPlugin: deviceCalendarPlugin,
          )..add(const LoadTodos()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) => AnalyticsBloc(
            analytics: context.read<FirebaseAnalytics>(),
          ),
        ),
      ],
      child: Builder(builder: (context) {
        final analyticsBloc = context.read<AnalyticsBloc>();
        analyticsBloc.add(AnalyticsEventPageView(
          screenName: 'TodoListPage',
          screenClassOverride: 'TodoListPage',
        ));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.error)));

      context.read<TodoBloc>().add(const ClearError());
    }

    if (state.updating) {
      EasyLoading.show(status: AppLocalizations.of(context)!.popupUpdating);
    } else {
      EasyLoading.dismiss();
    }
  }

  Widget _buildBody(BuildContext context, TodoState state) {
    final bloc = context.read<TodoBloc>();
    final todoList = TodoListWidget(
      todos: state.filteredTodos,
      onToggle: (todo) {
        bloc.add(ToggleTodo(todo));
      },
      onDelete: (todo) {
        bloc.add(DeleteTodo(todo.id ?? ''));
      },
    );

    final calendar = TableCalendarWidget(
      onDaySelected: (selectedDay) {
        bloc.add(SelectDay(selectedDay));
        Navigator.of(context).pushNamed('/select_day', arguments: {
          'selectedDate': selectedDay,
          'todos': state.todos,
        });
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
        : [calendar.toSliver(), todoList].toMultiSliver();
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
        inactiveWidget:
            Text(AppLocalizations.of(context)!.ptrInactive).center(),
        pullToRefreshWidget:
            Text(AppLocalizations.of(context)!.ptrPullToRefresh).center(),
        releaseToRefreshWidget:
            Text(AppLocalizations.of(context)!.ptrReleaseToRefresh).center(),
        refreshCompleteWidget:
            Text(AppLocalizations.of(context)!.ptrRefreshComplete).center(),
      ),
    );
  }
}
