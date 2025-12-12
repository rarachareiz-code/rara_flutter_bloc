import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/item_cubit.dart';
import '../models/item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Edit Dialog ---
  void _showEditDialog(BuildContext context, Item item) {
    final editController = TextEditingController(text: item.title);

    showDialog(
      context: context,
      builder: (_) {
        // Use Builder to ensure the dialog context can access ItemCubit
        return Builder(
          builder: (context) {
            return AlertDialog(
              title: const Text('Edit item'),
              content: TextField(
                controller: editController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Title'),
                onSubmitted: (_) => Navigator.of(context).pop(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newTitle = editController.text.trim();
                    if (newTitle.isNotEmpty) {
                      context.read<ItemCubit>().updateTitle(item.id, newTitle);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ItemCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes (Cubit + Persistence)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear all',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear all items?'),
                  content: const Text('This will delete all saved items.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Clear')),
                  ],
                ),
              );
              if (confirm == true) cubit.clearAll();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Add New Item ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add new item',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        final text = value.trim();
                        if (text.isNotEmpty) {
                          cubit.add(text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        cubit.add(text);
                        _controller.clear();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // --- Item List ---
            Expanded(
              child: BlocBuilder<ItemCubit, List<Item>>(
                builder: (context, items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No items yet — add some!'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: Key(item.id),
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => cubit.delete(item.id),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isDone,
                            onChanged: (_) => cubit.toggleDone(item.id),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text('${item.createdAt.toLocal()}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog(context, item),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
