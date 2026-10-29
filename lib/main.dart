import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF82AFFF)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _taskController = TextEditingController();
  final _tasks = <String>['tarea5', 'tarea1', 'tarea4', 'tarea2', 'tarea3'];
  int? _revealedTaskIndex;
  double _dragOffset = 0;
  double _slideOffset = 0;

  static const _actionsWidth = 136.0;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final task = _taskController.text.trim();
    if (task.isEmpty) return;

    setState(() {
      _tasks.add(task);
      _taskController.clear();
    });
  }

  Future<void> _editTask(int index) async {
    var editedValue = _tasks[index];
    final editedTask = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextFormField(
          autofocus: true,
          initialValue: editedValue,
          decoration: const InputDecoration(labelText: 'Tarea'),
          onChanged: (value) => editedValue = value,
          onFieldSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, editedValue.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (editedTask != null && editedTask.isNotEmpty && mounted) {
      setState(() => _tasks[index] = editedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa una tarea...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  width: 40,
                  child: IconButton.filled(
                    onPressed: _addTask,
                    tooltip: 'Agregar tarea',
                    icon: const Icon(Icons.add, size: 20),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isRevealed = _revealedTaskIndex == index;
                final offset = isRevealed ? _slideOffset : 0.0;

                return SizedBox(
                  height: 43,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned.fill(
                        child: isRevealed
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _taskActionButton(
                                    color: Colors.blue,
                                    icon: Icons.edit,
                                    label: 'Editar tarea',
                                    onPressed: () => _editTask(index),
                                  ),
                                  _taskActionButton(
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    label: 'Borrar tarea',
                                    onPressed: () {
                                      setState(() {
                                        _tasks.removeAt(index);
                                        _revealedTaskIndex = null;
                                        _slideOffset = 0;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        left: offset,
                        right: -offset,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onHorizontalDragStart: (_) {
                            _dragOffset = _revealedTaskIndex == index
                                ? _slideOffset
                                : 0;
                          },
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _dragOffset = (_dragOffset + details.delta.dx)
                                  .clamp(-_actionsWidth, 0.0);
                              _slideOffset = _dragOffset;
                              _revealedTaskIndex = _dragOffset < -24
                                  ? index
                                  : null;
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            setState(() {
                              final shouldReveal =
                                  _dragOffset <= -_actionsWidth / 2 ||
                                  (details.primaryVelocity ?? 0) < -500;
                              _revealedTaskIndex = shouldReveal ? index : null;
                              _slideOffset = shouldReveal ? -_actionsWidth : 0;
                            });
                          },
                          onTap: isRevealed
                              ? () => setState(() {
                                  _revealedTaskIndex = null;
                                  _slideOffset = 0;
                                })
                              : null,
                          child: ColoredBox(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.drag_handle,
                                        color: Colors.grey,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskActionButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: _actionsWidth / 2,
      child: ColoredBox(
        color: color,
        child: IconButton(
          onPressed: onPressed,
          tooltip: label,
          icon: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
