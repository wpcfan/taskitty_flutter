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
  }) : super(const TodoState()) {
    on<LoadTodos>((event, emit) => _mapLoadTodosToState(event, emit));
    on<AddTodo>((event, emit) => _mapAddTodoToState(event, emit));
    on<UpdateTodo>((event, emit) => _mapUpdateTodoToState(event, emit));
    on<DeleteTodo>((event, emit) => _mapDeleteTodoToState(event, emit));
    on<ToggleTodo>((event, emit) => _mapToggleTodoToState(event, emit));
    on<ClearError>((event, emit) => _mapClearErrorToState(event, emit));
    on<SearchTodos>((event, emit) => _mapSearchTodosToState(event, emit));
  }

  void _mapToggleTodoToState(ToggleTodo event, Emitter<TodoState> emit) async {
    final updatedTodo = event.todo.copyWith(completed: !event.todo.completed);
    await _mapUpdateTodoToState(
        UpdateTodo(
          updatedTodo,
        ),
        emit);
  }

  Future<void> _mapLoadTodosToState(
      LoadTodos event, Emitter<TodoState> emit) async {
    emit(state.copyWith(loading: true));
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
        emit(state.copyWith(loading: false));
      } else {
        final List<Todo> mappedTodos = todos
            .data()!
            .entries
            .map((e) => Todo.fromMap(e.value, e.key))
            .toList();
        // order todos by updatedAt
        mappedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        emit(state.copyWith(
          todos: mappedTodos,
          filteredTodos: mappedTodos,
          loading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
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
      emit(state.copyWith(todos: [event.todo, ...state.todos], loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> _mapUpdateTodoToState(
      UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(auth.currentUser!.uid)
          .update(<String, dynamic>{
        event.updatedTodo.id!: event.updatedTodo.toMap()
      });
      final updatedTodos = state.todos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      updatedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final updatedFilteredTodos = state.filteredTodos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      updatedFilteredTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      emit(state.copyWith(
        todos: updatedTodos,
        filteredTodos: updatedFilteredTodos,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> _mapDeleteTodoToState(
      DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await firestore
          .collection(collectionName)
          .doc(auth.currentUser!.uid)
          .update(<String, dynamic>{event.id: FieldValue.delete()});
      final updatedTodos =
          state.todos.where((todo) => todo.id != event.id).toList();
      final updatedFilteredTodos =
          state.filteredTodos.where((todo) => todo.id != event.id).toList();
      emit(state.copyWith(
        todos: updatedTodos,
        filteredTodos: updatedFilteredTodos,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  void _mapClearErrorToState(ClearError event, Emitter<TodoState> emit) {
    emit(state.copyWith(error: ''));
  }

  void _mapSearchTodosToState(SearchTodos event, Emitter<TodoState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredTodos: state.todos));
      return;
    }
    final searchedTodos = state.todos
        .where((todo) =>
            todo.title.toLowerCase().contains(event.query.toLowerCase()))
        .toList();
    searchedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    emit(state.copyWith(filteredTodos: searchedTodos));
  }
}
