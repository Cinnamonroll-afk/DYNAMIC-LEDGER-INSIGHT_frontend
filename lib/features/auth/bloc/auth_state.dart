import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage];
}
