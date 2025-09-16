import 'package:dire_di_flutter/dire_di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

@Controller()
class UserBloc extends Bloc<UserEvent, UserState> {
  @Autowired()
  late UserRepository userRepository;

  UserBloc() : super(const UserState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStateStatus.loading));

    try {
      await Future<void>.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay

      // Simulate getting users from repository
      final users = await userRepository.getAllUsers();
      emit(state.copyWith(
        status: UserStateStatus.loaded,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStateStatus.loading));

    try {
      await Future<void>.delayed(
          const Duration(milliseconds: 300)); // Simulate network delay

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        email: event.email,
      );

      // Add to existing users
      final updatedUsers = [...state.users, newUser];

      emit(state.copyWith(
        status: UserStateStatus.loaded,
        users: updatedUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStateStatus.loading));

    try {
      await Future<void>.delayed(
          const Duration(milliseconds: 300)); // Simulate network delay

      // Remove user from list
      final updatedUsers =
          state.users.where((user) => user.id != event.userId).toList();

      emit(state.copyWith(
        status: UserStateStatus.loaded,
        users: updatedUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserStateStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
