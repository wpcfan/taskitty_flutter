import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../components/components.dart';
import '../models/models.dart';

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
            // TODO: implement listener
          },
          builder: (context, state) {
            final bloc = context.read<TodoBloc>();
            return Scaffold(
              appBar: AppBar(
                title: const Text('Todos'),
              ),
              body: _buildBody(context, state),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final Todo todo =
                      await Navigator.pushNamed(context, '/add_todo') as Todo;
                  bloc.add(AddTodo(todo));
                },
                child: const Icon(Icons.add),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildBody(BuildContext context, TodoState state) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return TodoListWidget(
      todos: state.todos,
      onToggle: (todo) {
        context.read<TodoBloc>().add(ToggleTodo(todo));
      },
      onDelete: (todo) {
        context.read<TodoBloc>().add(DeleteTodo(todo.id ?? ''));
      },
    );
  }
}
