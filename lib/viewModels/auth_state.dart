import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  final bool isNewUser;
  const AuthState(this.isNewUser);
}

class AuthInitial extends AuthState {
  const AuthInitial(super.isNewUser);
}

class AuthLoading extends AuthState {
  const AuthLoading(super.isNewUser);
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(super.isNewUser, this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated(super.isNewUser);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(super.isNewUser, this.message);
}
