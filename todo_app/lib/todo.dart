class Todo {
  final int id;
  final String title;
  final bool isDone;

  const Todo({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Todo copyWith({bool? isDone}) => Todo(
        id: id,
        title: title,
        isDone: isDone ?? this.isDone,
      );
}
