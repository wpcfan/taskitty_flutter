import 'package:equatable/equatable.dart';

import '../models/models.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final List<Todo> filteredTodos;
  final bool loading;
  final bool updating;
  final String error;
  final List<String> topTags;
  final DateTime? selectedDate;

  List<Todo> get todosBySelectedDate => todos
      .where((todo) =>
          todo.dueDate != null &&
          todo.dueDate!.year == selectedDate!.year &&
          todo.dueDate!.month == selectedDate!.month &&
          todo.dueDate!.day == selectedDate!.day)
      .toList();

  const TodoState({
    this.todos = const [],
    this.filteredTodos = const [],
    this.loading = false,
    this.error = '',
    this.topTags = const [],
    this.selectedDate,
    this.updating = false,
  });

  @override
  List<Object?> get props => [
        todos,
        filteredTodos,
        loading,
        error,
        topTags,
        selectedDate,
        updating,
      ];

  TodoState copyWith({
    List<Todo>? todos,
    List<Todo>? filteredTodos,
    bool? loading,
    String? error,
    List<String>? topTags,
    DateTime? selectedDate,
    bool? updating,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      topTags: topTags ?? this.topTags,
      selectedDate: selectedDate ?? this.selectedDate,
      updating: updating ?? this.updating,
    );
  }

  @override
  String toString() {
    return 'TodoState { todos: $todos, filteredTodos: $filteredTodos, loading: $loading, error: $error, topTags: $topTags, selectedDate: $selectedDate, updating: $updating }';
  }
}
