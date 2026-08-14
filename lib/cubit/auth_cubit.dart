import 'package:flutter_bloc/flutter_bloc.dart';

import '../api_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService apiService;

  AuthCubit(this.apiService) : super(AuthInitial());

  Future<void> login(
    String username,
    String password,
  ) async {
    emit(AuthLoading());

    try {
      final success = await apiService.login(
        username,
        password,
      );

      if (success) {
        emit(AuthLoggedIn());
      } else {
        emit(AuthError('Invalid username or password'));
      }
    } catch (e) {
      emit(AuthError('Login failed'));
    }
  }

  void logout() {
    apiService.logout();

    emit(AuthLoggedOut());
  }
}