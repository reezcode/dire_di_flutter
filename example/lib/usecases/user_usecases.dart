import 'package:dire_di_flutter/dire_di.dart';

import '../bloc/user_state.dart';
import '../repositories/user_repository.dart';

@UseCase()
class GetAllUsersUseCase {
  @Autowired()
  late UserRepository userRepository;

  Future<List<User>> execute() async {
    return await userRepository.getAllUsers();
  }
}

@UseCase()
class CreateUserUseCase {
  @Autowired()
  late UserRepository userRepository;

  Future<User> execute(String name, String email) async {
    return await userRepository.createUser(name, email);
  }
}

@UseCase()
class DeleteUserUseCase {
  @Autowired()
  late UserRepository userRepository;

  Future<void> execute(String userId) async {
    await userRepository.deleteUser(userId);
  }
}
