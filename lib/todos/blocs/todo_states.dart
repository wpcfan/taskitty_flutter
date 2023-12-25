import 'package:equatable/equatable.dart';

import '../models/models.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final bool loading;
  final String error;

  const TodoState({
    this.todos = const [],
    this.filteredTodos = const [],
    this.loading = false,
    this.error = '',
  });

  @override
  List<Object?> get props => [todos, filteredTodos, loading, error];

  TodoState copyWith({
    List<Todo>? todos,
    List<Todo>? filteredTodos,
    bool? loading,
    String? error,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'TodoState { todos: $todos, filteredTodos: $filteredTodos, loading: $loading, error: $error }';
  }
}
