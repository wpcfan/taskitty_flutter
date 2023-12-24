import 'package:equatable/equatable.dart';

import '../models/models.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final bool loading;
  final String error;

  const TodoState({
    this.todos = const [],
    this.loading = false,
    this.error = '',
  });

  @override
  List<Object?> get props => [todos, loading, error];

  TodoState copyWith({
    List<Todo>? todos,
    bool? loading,
    String? error,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'TodoState { todos: $todos, loading: $loading, error: $error }';
  }
}
