import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String userName;

  const AuthSignUpRequested(this.email, this.password, this.userName);

  @override
  List<Object> get props => [email, password, userName];
}

class AuthLogoutRequested extends AuthEvent {}
