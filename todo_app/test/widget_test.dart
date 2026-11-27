import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:todo_app/database_helper.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/todo_bloc.dart';
import 'package:todo_app/todo_event.dart';
import 'package:todo_app/todo_screen.dart';

/// In-memory stand-in for sqflite, which cannot run inside widget tests.
/// Hands out ids the way AUTOINCREMENT does, so the Stage 3 id bug would show.
class FakeDb extends DatabaseHelper {
  final rows = <int, Todo>{};
  int _nextId = 1;

  @override
  Future<int> insertTodo(String title) async {
    final id = _nextId++;
    rows[id] = Todo(id: id, title: title);
    return id;
  }

  @override
  Future<List<Todo>> getTodos() async => rows.values.toList();

  @override
  Future<void> updateIsDone(int id, bool isDone) async {
    rows[id] = rows[id]!.copyWith(isDone: isDone);
  }

  @override
  Future<void> deleteTodo(int id) async => rows.remove(id);
}

Widget app(FakeDb db) => BlocProvider(
      create: (_) => TodoBloc(db)..add(LoadTodos()),
      child: const MaterialApp(home: TodoScreen()),
    );

void main() {
  testWidgets('add, toggle, delete are saved and survive a restart',
      (tester) async {
    final db = FakeDb();
    await tester.pumpWidget(app(db));

    for (final title in ['Milk', 'Eggs', 'Bread']) {
      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }
    expect(find.byType(CheckboxListTile), findsNWidgets(3));

    await tester.tap(find.text('Eggs'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first); // Milk
    await tester.pumpAndSettle();

    // The database agrees with the screen: same ids, same done flag.
    expect(db.rows.values.map((t) => t.title), ['Eggs', 'Bread']);
    expect(db.rows.values.first.isDone, isTrue);

    // Restart: a brand-new widget tree and Bloc reading the same database.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsNothing);
    final tiles = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(tiles.map((t) => t.title is Text ? (t.title as Text).data : null),
        ['Eggs', 'Bread']);
    expect(tiles.map((t) => t.value), [true, false]);
  });
}
