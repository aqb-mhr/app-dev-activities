# Todo – BLoC + sqflite (Class Activity, CSE-450)

The finished **Stage 4** app from `Todo-BLoC-Sqflite-Class-Activity.pdf`.

## Run
```
flutter pub get
flutter run          # on an Android emulator/phone (plain sqflite has no Windows/web support)
flutter test         # widget test using an in-memory fake database
```

## Files
| File | Role |
|---|---|
| `lib/todo.dart` | `Todo` model (`id`, `title`, `isDone`) |
| `lib/todo_event.dart` | `LoadTodos`, `AddTodo`, `ToggleTodo`, `DeleteTodo` |
| `lib/todo_state.dart` | `TodoState` holding the list |
| `lib/database_helper.dart` | sqflite: opens `todos.db`, creates the table, insert / query / update / delete |
| `lib/todo_bloc.dart` | Handles each event: **write to the DB first, then emit new state** |
| `lib/todo_screen.dart` | UI: text field + add button, list of checkbox tiles with delete icon |
| `lib/main.dart` | `BlocProvider` creates `TodoBloc(DatabaseHelper())..add(LoadTodos())` |

## How it works
1. **Launch** → `LoadTodos` → `getTodos()` reads every row from `todos.db` → screen shows them.
2. **Add** → `insertTodo(title)` returns the id SQLite assigned (`AUTOINCREMENT`) → the `Todo` is built
   *with that id* → added to state.
3. **Toggle** → `updateIsDone(id, !isDone)` `UPDATE ... WHERE id = ?` → state updated.
4. **Delete** → `DELETE ... WHERE id = ?` → removed from state.

The UI only talks to the Bloc; the Bloc only talks to `DatabaseHelper`. That is why `TodoScreen`
didn't need to change between Stage 1 (memory only) and Stage 4 (database).

### The Stage 3 bug (and why this code avoids it)
If the Bloc makes its own id (`DateTime.now().millisecondsSinceEpoch`) and *also* inserts the row,
the screen's id and the database's id differ. `ToggleTodo` then updates a row that doesn't exist (0 rows
affected, no error), so the checkmark is lost on restart. Rule: **an id is only real once the database
has assigned it — build the object after the insert.**

## Differences from the PDF listings
- Added the `LoadTodos` event class (the manual uses it but never defines it) and all missing imports.
- `TodoScreen` is a `StatefulWidget` so the `TextEditingController` isn't recreated on every rebuild
  (and is disposed). Pressing Enter also adds a todo.
- `path: ^1.9.1` instead of `^1.9.0` (required by the current `flutter_test`), and
  `sqflite` resolves to 2.4.x — 2.3.0 no longer compiles on Android with current Flutter.
- Imports use `package:material_ui/material_ui.dart`, which is what this Flutter version's template uses
  in place of `package:flutter/material.dart`.

## Live demo checklist (from the manual)
1. Add 3 todos, check one, delete one.
2. Fully stop and relaunch → the todos are back, with the right one checked.
3. Delete one, relaunch → it stays gone.
4. `todos.db` is a real file: print `await getDatabasesPath()` to see where it is.
