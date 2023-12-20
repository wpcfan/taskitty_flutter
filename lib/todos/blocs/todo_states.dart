import 'package:equatable/equatable.dart';

import '../models/models.dart';

abstract class TodoState extends Equatable {
  const TodoState();
}

class TodoInitial extends TodoState {
  const TodoInitial();

  @override
  List<Object> get props => [];
}

class TodoLoading extends TodoState {
  const TodoLoading();

  @override
  List<Object> get props => [];
}

class TodoLoaded extends TodoState {
  final List<Todo> todos;

  const TodoLoaded([this.todos = const []]);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'TodosLoaded { todos: $todos }';
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}

class TodoAdded extends TodoState {
  final Todo todo;

  const TodoAdded(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'TodoAdded { todo: $todo }';
}

class TodoUpdated extends TodoState {
  final Todo updatedTodo;

  const TodoUpdated(this.updatedTodo);

  @override
  List<Object> get props => [updatedTodo];

  @override
  String toString() => 'TodoUpdated { updatedTodo: $updatedTodo }';
}

class TodoDeleted extends TodoState {
  final String id;

  const TodoDeleted(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'TodoDeleted { todo id: $id }';
}
