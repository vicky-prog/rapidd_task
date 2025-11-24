import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rapidd_task/init.dart';
import 'package:rapidd_task/repository/task_repository.dart';
import 'package:rapidd_task/viewModels/auth_viewmodel.dart';
import 'package:rapidd_task/views/task_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();

    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    _sub = appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) async {
    debugPrint("Deep Link: $uri");

    if (uri.host == "task" && uri.pathSegments.isNotEmpty) {
      final taskId = uri.pathSegments[0];

      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final task = await ref.read(taskRepositoryProvider).getTaskById(taskId);

        if (task != null && !task.sharedWith.contains(currentUser.uid)) {
          // Add the current user to the sharedWith array
          await ref
              .read(taskRepositoryProvider)
              .shareTask(taskId, currentUser.uid);
        }
      }

      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TaskListScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: const Root(),
      debugShowCheckedModeBanner: false,
    );
  }
}
