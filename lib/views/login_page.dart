import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rapidd_task/viewModels/auth_state.dart';
import 'package:rapidd_task/viewModels/auth_viewmodel.dart';
import 'package:rapidd_task/views/task_page.dart';

class LoginPage extends ConsumerWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }

      if (next is Authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TaskListScreen()),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              width: size.width < 500 ? double.infinity : 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Please ${authState is AuthInitial && authState.isNewUser ? "Sign Up" : "Sign In"} to continue",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState is AuthLoading
                          ? null
                          : () {
                              if (authState is AuthInitial &&
                                  authState.isNewUser) {
                                ref
                                    .read(authProvider.notifier)
                                    .signup(email.text, password.text);
                              } else {
                                ref
                                    .read(authProvider.notifier)
                                    .login(email.text, password.text);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: authState is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              authState is AuthInitial && authState.isNewUser
                                  ? "Sign Up"
                                  : "Sign In",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).toggleMode();
                    },
                    child: Text(
                      authState is AuthInitial && authState.isNewUser
                          ? "Already have an account? Login"
                          : "Don’t have an account? Register",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
