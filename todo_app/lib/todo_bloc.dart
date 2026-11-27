import 'package:flutter_bloc/flutter_bloc.dart';

import 'database_helper.dart';
import 'todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final DatabaseHelper _db;

  TodoBloc(this._db) : super(const TodoState()) {
    on<LoadTodos>((event, emit) async {
      emit(state.copyWith(todos: await _db.getTodos()));
    });

    on<AddTodo>((event, emit) async {
      // Insert FIRST, then build the Todo with the id the database assigned.
      final id = await _db.insertTodo(event.title);
      final newTodo = Todo(id: id, title: event.title);
      emit(state.copyWith(todos: [...state.todos, newTodo]));
    });

    on<ToggleTodo>((event, emit) async {
      final current = state.todos.firstWhere((t) => t.id == event.id);
      await _db.updateIsDone(event.id, !current.isDone);
      final updated = state.todos
          .map((t) => t.id == event.id ? t.copyWith(isDone: !t.isDone) : t)
          .toList();
      emit(state.copyWith(todos: updated));
    });

    on<DeleteTodo>((event, emit) async {
      await _db.deleteTodo(event.id);
      emit(state.copyWith(
        todos: state.todos.where((t) => t.id != event.id).toList(),
      ));
    });
  }
}
