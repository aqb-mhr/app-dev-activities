import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'database_helper.dart';
import 'todo_bloc.dart';
import 'todo_event.dart';
import 'todo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc(DatabaseHelper())..add(LoadTodos()),
      child: const MaterialApp(home: TodoScreen()),
    );
  }
}
