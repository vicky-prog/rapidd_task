import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rapidd_task/viewModels/auth_state.dart';
import '../repository/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is Authenticated) {
    return authState.user;
  }
  return null;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  bool _isNewUser = false;

  AuthNotifier(this._repo) : super(const AuthInitial(false)) {
    _init();
  }

  Future<void> _init() async {
    final currentUser = _repo.currentUser();
    if (currentUser != null) {
      state = Authenticated(_isNewUser, currentUser);
    } else {
      state = Unauthenticated(_isNewUser);
    }
  }

  void toggleMode() {
    _isNewUser = !_isNewUser;
    state = AuthInitial(_isNewUser);
  }

  Future<void> login(String email, String password) async {
    if (!_validate(email, password)) return;

    state = AuthLoading(_isNewUser);
    try {
      final user = await _repo.signIn(email, password);
      state = Authenticated(_isNewUser, user!);
    } catch (e) {
      state = AuthError(_isNewUser, e.toString());
      _reset();
    }
  }

  Future<void> signup(String email, String password) async {
    if (!_validate(email, password)) return;

    state = AuthLoading(_isNewUser);
    try {
      final user = await _repo.signUp(email, password);
      state = Authenticated(_isNewUser, user!);
    } catch (e) {
      state = AuthError(_isNewUser, e.toString());
      _reset();
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = Unauthenticated(_isNewUser);
    _reset();
  }

  void _reset() {
    Future.delayed(Duration(milliseconds: 200), () {
      state = AuthInitial(_isNewUser);
    });
  }

  bool _validate(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      state = AuthError(_isNewUser, "Email and password must not be empty");
      _reset();
      return false;
    }

    if (!email.contains("@")) {
      state = AuthError(_isNewUser, "Invalid email format");
      _reset();
      return false;
    }

    if (password.length < 6) {
      state = AuthError(_isNewUser, "Password must be at least 6 characters");
      _reset();
      return false;
    }

    return true;
  }
}
