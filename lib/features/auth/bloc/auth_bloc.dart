import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fincontrol/features/auth/data/repositories/auth_repository.dart';
import 'package:fincontrol/features/auth/bloc/auth_event.dart';
import 'package:fincontrol/features/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required this._authRepository}) 
      : super(const AuthState()) {
    
    on<AuthLoginRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.loading));
      try {
        await _authRepository.login(event.email, event.password);
        emit(const AuthState(status: AuthStatus.authenticated));
      } catch (e) {
        emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
      }
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.loading));
      try {
        await _authRepository.register(event.userName, event.email, event.password);
        emit(const AuthState(status: AuthStatus.authenticated));
      } catch (e) {
        emit(AuthState(status: AuthStatus.error, errorMessage: e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(const AuthState(status: AuthStatus.loading));
      await _authRepository.logout();
      emit(const AuthState(status: AuthStatus.initial));
    });
  }
}
