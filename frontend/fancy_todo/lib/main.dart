import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/todo.dart';
import 'services/api_client.dart';
import 'package:uuid/uuid.dart';

//import 'package:flutter_dotenv/flutter_dotenv.dart';

// Future<void> main() async {
//   await dotenv.load(fileName: ".env");
//   runApp(FancyTodoApp());
// }

void main() {
  runApp(const FancyTodoApp());
}

class FancyTodoApp extends StatelessWidget {
  const FancyTodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fancy TODO top app', //Change the title CARMEN here
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});
  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  final api = ApiClient();
  List<Todo> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      items = await api.listTodos();
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _addOrEdit([Todo? original]) async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (_) => TodoDialog(initial: original),
    );
    if (result == null) return;
    if (original == null) {
      await api.create(result);
    } else {
      await api.update(result);
    }
    _refresh();
  }

  Future<void> _toggleDone(Todo t) async {
    await api.update(t.copyWith(isDone: !t.isDone));
    _refresh();
  }

  Future<void> _delete(Todo t) async {
    await api.delete(t.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fancy TODO'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: items.isEmpty
                  ? const Center(child: Text('No tasks yet. Tap + to add.'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final t = items[i];
                        final dueStr = t.due != null
                            ? DateFormat.yMMMd().format(t.due!)
                            : 'No due date';
                        final priColor = [
                          null,
                          Colors.lightBlue,
                          Colors.orange,
                          Colors.red
                        ][t.priority];
                        return Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            leading: Checkbox(
                              value: t.isDone,
                              onChanged: (_) => _toggleDone(t),
                            ),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                decoration: t.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                if (t.description?.isNotEmpty == true)
                                  Text(t.description!),
                                Chip(
                                    label: Text('P${t.priority}'),
                                    backgroundColor:
                                        priColor?.withOpacity(0.15)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.event, size: 16),
                                    const SizedBox(width: 4),
                                    Text(dueStr),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (k) {
                                if (k == 'edit') _addOrEdit(t);
                                if (k == 'delete') _delete(t);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class TodoDialog extends StatefulWidget {
  final Todo? initial;
  const TodoDialog({super.key, this.initial});
  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  final _form = GlobalKey<FormState>();
  late TextEditingController title;
  late TextEditingController desc;
  int priority = 2;
  DateTime? due;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.initial?.title ?? '');
    desc = TextEditingController(text: widget.initial?.description ?? '');
    priority = widget.initial?.priority ?? 2;
    due = widget.initial?.due;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'New Task' : 'Edit Task'),
      content: Form(
        key: _form,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                    labelText: 'Title', prefixIcon: Icon(Icons.title)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: desc,
                decoration: const InputDecoration(
                    labelText: 'Description', prefixIcon: Icon(Icons.notes)),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Priority:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: priority,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Low')),
                      DropdownMenuItem(value: 2, child: Text('Medium')),
                      DropdownMenuItem(value: 3, child: Text('High')),
                    ],
                    onChanged: (v) => setState(() => priority = v ?? 2),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now.subtract(const Duration(days: 1)),
                        lastDate: now.add(const Duration(days: 365)),
                        initialDate: due ?? now,
                      );
                      if (picked != null) setState(() => due = picked);
                    },
                    icon: const Icon(Icons.event),
                    label: Text(due == null
                        ? 'Due date'
                        : DateFormat.yMMMd().format(due!)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            final t = Todo(
              id: widget.initial?.id ?? Uuid().v4().toString(),
              title: title.text.trim(),
              description: desc.text.trim().isEmpty ? null : desc.text.trim(),
              priority: priority,
              due: due,
              isDone: widget.initial?.isDone ?? false,
            );
            Navigator.pop(context, t);
          },
          icon: const Icon(Icons.check),
          label: const Text('Save'),
        ),
      ],
    );
  }
}
