import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rapidd_task/viewModels/auth_viewmodel.dart';
import 'package:rapidd_task/viewModels/task_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      final provider = ref.read(taskViewModelProvider.notifier);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        setState(() => _isLoadingMore = true);
        provider.fetchNextPage(user.uid).whenComplete(() {
          if (mounted) setState(() => _isLoadingMore = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tasksAsync = ref.watch(tasksProvider(user.uid));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Shared TODOs"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: tasksAsync.when(
          data: (tasks) => tasks.isEmpty
              ? const Center(
                  child: Text(
                    "No tasks yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: tasks.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == tasks.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final t = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: t.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                final deepLink = "myapp://task/${t.id}";
                                // ignore: deprecated_member_use
                                Share.share("Join my shared task:\n$deepLink");
                              },
                            ),
                            Checkbox(
                              value: t.completed,
                              activeColor: Colors.deepPurple,
                              onChanged: (_) {
                                ref
                                    .read(taskViewModelProvider.notifier)
                                    .toggleTask(t);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 3)),
          error: (e, _) => Center(
            child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: AddTaskBar(),
      ),
    );
  }
}

class AddTaskBar extends ConsumerWidget {
  AddTaskBar({super.key});
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: user != null,
            decoration: InputDecoration(
              hintText: user != null ? "New task" : "Login to add tasks",
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: user != null ? Colors.deepPurple : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: user == null
                ? null
                : () {
                    if (_controller.text.trim().isEmpty) return;
                    ref
                        .read(taskViewModelProvider.notifier)
                        .createTask(_controller.text.trim(), user.uid);
                    _controller.clear();
                  },
          ),
        ),
      ],
    );
  }
}
