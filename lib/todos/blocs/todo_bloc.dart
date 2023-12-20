import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart';
import 'todo_events.dart';
import 'todo_states.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  static const collectionName = 'todos';
  TodoBloc({
    required this.firestore,
    required this.auth,
  }) : super(const TodoInitial()) {
    on<LoadTodos>((event, emit) => _mapLoadTodosToState(event, emit));
    on<AddTodo>((event, emit) => _mapAddTodoToState(event, emit));
    on<UpdateTodo>((event, emit) => _mapUpdateTodoToState(event, emit));
    on<DeleteTodo>((event, emit) => _mapDeleteTodoToState(event, emit));
  }

  Future<void> _mapLoadTodosToState(
      LoadTodos event, Emitter<TodoState> emit) async {
    emit(const TodoLoading());
    try {
      final todos = await firestore
          .collection(collectionName)
          .doc(auth.currentUser!.uid)
          .get();
      if (todos.data() == null) {
        await firestore
            .collection(collectionName)
            .doc(auth.currentUser!.uid)
            .set(<String, dynamic>{});
        emit(const TodoLoaded([]));
      } else {
        final List<Todo> mappedTodos = todos
            .data()!
            .entries
            .map((e) => Todo.fromMap(e.value, e.key))
            .toList();
        emit(TodoLoaded(mappedTodos));
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _mapAddTodoToState(
      AddTodo event, Emitter<TodoState> emit) async {
    try {
      final todos = await firestore
          .collection(collectionName)
          .doc(auth.currentUser!.uid)
          .get();

      await todos.reference
          .update(<String, dynamic>{event.todo.id!: event.todo.toMap()});
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _mapUpdateTodoToState(
      UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(event.updatedTodo.id)
          .update(event.updatedTodo.toMap());
      emit(TodoUpdated(event.updatedTodo));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _mapDeleteTodoToState(
      DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await firestore.collection(collectionName).doc(event.id).delete();
      emit(TodoDeleted(event.id));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }
}
