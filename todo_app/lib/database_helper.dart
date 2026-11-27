import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'todo.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'todos.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isDone INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  /// Returns the id SQLite assigned to the new row.
  Future<int> insertTodo(String title) async {
    final db = await database;
    return db.insert('todos', {'title': title, 'isDone': 0});
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final rows = await db.query('todos');
    return rows
        .map((r) => Todo(
              id: r['id'] as int,
              title: r['title'] as String,
              isDone: (r['isDone'] as int) == 1,
            ))
        .toList();
  }

  Future<void> updateIsDone(int id, bool isDone) async {
    final db = await database;
    await db.update(
      'todos',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
