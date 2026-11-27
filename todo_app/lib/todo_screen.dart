import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'todo_bloc.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Kept in State (not in build) so a rebuild does not wipe the typed text.
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<TodoBloc>().add(AddTodo(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'New todo'),
                onSubmitted: (_) => _add(),
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: _add),
          ]),
        ),
        Expanded(
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) => ListView(
              children: state.todos
                  .map((t) => CheckboxListTile(
                        key: ValueKey(t.id),
                        value: t.isDone,
                        title: Text(t.title),
                        onChanged: (_) =>
                            context.read<TodoBloc>().add(ToggleTodo(t.id)),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              context.read<TodoBloc>().add(DeleteTodo(t.id)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ]),
    );
  }
}
