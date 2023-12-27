import 'package:equatable/equatable.dart';

import '../models/models.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final bool loading;
  final String error;
  final List<String> topTags;

  const TodoState({
    this.todos = const [],
    this.filteredTodos = const [],
    this.loading = false,
    this.error = '',
    this.topTags = const [],
  });

  @override
  List<Object?> get props => [todos, filteredTodos, loading, error, topTags];

  TodoState copyWith({
    List<Todo>? todos,
    List<Todo>? filteredTodos,
    bool? loading,
    String? error,
    List<String>? topTags,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      topTags: topTags ?? this.topTags,
    );
  }

  @override
  String toString() {
    return 'TodoState { todos: $todos, filteredTodos: $filteredTodos, loading: $loading, error: $error, topTags: $topTags }';
  }
}
