import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:table_calendar/table_calendar.dart';

import '../blocs/blocs.dart';
import '../components/components.dart';

class TodoListPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const TodoListPage({
    super.key,
    required this.firestore,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoBloc>(
      create: (context) => TodoBloc(
        firestore: firestore,
        auth: auth,
      )..add(const LoadTodos()),
      child: Builder(builder: (context) {
        return BlocConsumer<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state.error.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                ),
              );

              context.read<TodoBloc>().add(const ClearError());
            }
          },
          builder: (context, state) {
            return _buildBody(context, state);
          },
        );
      }),
    );
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

    return Scaffold(
      body: MyCustomScrollView(
        decoration: decoration,
        sliverAppBar: MySliverAppBar(
          decoration: decoration,
          onRightIconTap: () => Navigator.of(context).pushNamed('/add_todo'),
          onChanged: (value) {
            bloc.add(SearchTodos(value));
          },
        ),
        sliver: MultiSliver(children: [
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: calendar,
            ),
          ),
          todoList
        ]),
        onRefresh: () async {
          bloc.add(const LoadTodos());
          await bloc.stream.firstWhere((state) => !state.loading);
        },
      ),
    );
  }
}
