abstract class TodoEvent {}

/// Reads every saved todo back from the database (sent once on launch).
class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  AddTodo(this.title);
}

class ToggleTodo extends TodoEvent {
  final int id;
  ToggleTodo(this.id);
}

class DeleteTodo extends TodoEvent {
  final int id;
  DeleteTodo(this.id);
}
