import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart';
import 'todo_events.dart';
import 'todo_states.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  static const collectionTodos = 'todos';
  static const collectionTags = 'tags';

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
    on<SelectDay>((event, emit) => _mapSelectDayToState(event, emit));
  }

  void _mapToggleTodoToState(
    ToggleTodo event,
    Emitter<TodoState> emit,
  ) async {
    final updatedTodo = event.todo.copyWith(completed: !event.todo.completed);
    await _mapUpdateTodoToState(UpdateTodo(updatedTodo), emit);
  }

  Future<void> _mapLoadTodosToState(
    LoadTodos event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final topTags = await getTopTags();
      final todos = await firestore
          .collection(collectionTodos)
          .doc(auth.currentUser!.uid)
          .get();
      if (todos.data() == null) {
        await firestore
            .collection(collectionTodos)
            .doc(auth.currentUser!.uid)
            .set(<String, dynamic>{});
        emit(state.copyWith(
          loading: false,
          topTags: topTags,
        ));
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
          topTags: topTags,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> _mapAddTodoToState(
    AddTodo event,
    Emitter<TodoState> emit,
  ) async {
    try {
      // get user todos
      final todos = await firestore
          .collection(collectionTodos)
          .doc(auth.currentUser!.uid)
          .get();
      // remove duplicate tags
      final uniqueTags = removeDuplicateTags(event.todo.tags ?? []);
      // update tag counts
      await updateTagCounts(uniqueTags);
      final updatedTodo = event.todo.copyWith(tags: uniqueTags);
      // update remote todo
      await todos.reference
          .update(<String, dynamic>{event.todo.id!: updatedTodo.toMap()});
      emit(
          state.copyWith(todos: [updatedTodo, ...state.todos], loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  Future<void> updateTagCounts(
    List<String> tags, {
    bool decrement = false,
  }) async {
    // 更新标签计数
    final tagsRef = firestore.collection(collectionTags);

    for (var tag in tags) {
      final tagRef = tagsRef.doc(tag);

      // 在Firebase事务中更新标签计数
      await firestore.runTransaction((transaction) async {
        final tagDoc = await transaction.get(tagRef);
        if (tagDoc.exists) {
          int count = tagDoc.data()!['count'];
          if (decrement) {
            count -= 1;
          } else {
            count += 1;
          }
          transaction.update(tagRef, {'count': count});
        } else {
          transaction.set(tagRef, {'count': 1});
        }
      });
    }
  }

  Future<List<String>> getTopTags({
    int limit = 10,
  }) async {
    // 获取所有标签，并按计数排序
    final tagsRef = firestore.collection(collectionTags);
    final sortedTags =
        await tagsRef.orderBy('count', descending: true).limit(limit).get();

    // 返回前十个标签
    return sortedTags.docs.map((tag) => tag.id).toList();
  }

  Future<void> _mapUpdateTodoToState(
    UpdateTodo event,
    Emitter<TodoState> emit,
  ) async {
    try {
      // update remote todo
      await firestore
          .collection(collectionTodos)
          .doc(auth.currentUser!.uid)
          .update(<String, dynamic>{
        event.updatedTodo.id!: event.updatedTodo.toMap()
      });
      // update local todo
      final updatedTodos = state.todos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      // order todos by updatedAt
      updatedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      // update filteredTodos
      final updatedFilteredTodos = state.filteredTodos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      // order filteredTodos by updatedAt
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
    DeleteTodo event,
    Emitter<TodoState> emit,
  ) async {
    try {
      // update tag counts
      await firestore
          .collection(collectionTodos)
          .doc(auth.currentUser!.uid)
          .update(<String, dynamic>{event.id: FieldValue.delete()});
      final tags =
          state.todos.firstWhere((todo) => todo.id == event.id).tags ?? [];
      // decrease tag counts
      await updateTagCounts(tags, decrement: true);

      final updatedTodos =
          state.todos.where((todo) => todo.id != event.id).toList();

      // order todos by updatedAt
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

  void _mapClearErrorToState(
    ClearError event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(error: ''));
  }

  void _mapSearchTodosToState(
    SearchTodos event,
    Emitter<TodoState> emit,
  ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredTodos: state.todos));
      return;
    }
    // filter todos by query
    final searchedTodos = state.todos
        .where((todo) => (todo.title ?? '')
            .toLowerCase()
            .contains(event.query.toLowerCase()))
        .toList();
    // order todos by updatedAt
    searchedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    // update filteredTodos
    emit(state.copyWith(filteredTodos: searchedTodos));
  }

  void _mapSelectDayToState(
    SelectDay event,
    Emitter<TodoState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.selectedDay));
  }

  List<String> removeDuplicateTags(List<String> tags) {
    return tags.map((tag) => tag.toLowerCase()).toSet().toList();
  }
}
