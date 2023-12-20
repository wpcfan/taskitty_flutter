import 'package:equatable/equatable.dart';

import '../models/models.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
}

class LoadTodos extends TodoEvent {
  const LoadTodos();

  @override
  List<Object> get props => [];
}

class AddTodo extends TodoEvent {
  final Todo todo;

  const AddTodo(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'AddTodo { todo: $todo }';
}

class ToggleTodo extends TodoEvent {
  final String id;

  const ToggleTodo(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'ToggleTodo { id: $id }';
}

class UpdateTodo extends TodoEvent {
  final Todo updatedTodo;

  const UpdateTodo(this.updatedTodo);

  @override
  List<Object> get props => [updatedTodo];

  @override
  String toString() => 'UpdateTodo { updatedTodo: $updatedTodo }';
}

class DeleteTodo extends TodoEvent {
  final String id;

  const DeleteTodo(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'DeleteTodo { id: $id }';
}
