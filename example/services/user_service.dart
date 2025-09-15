import 'package:dire_di_flutter/dire_di.dart';

import '../repositories/user_repository.dart';
import '../services/database_service.dart';

@Service()
class UserService {

  UserService(ConfigurationService config)
      : serviceName = 'UserService-${config.environment}';
  final String serviceName;

  @Autowired()
  late UserRepository userRepository;

  void getUserById(String id) {
    print('$serviceName: Getting user $id');
    userRepository.findUser(id);
  }
}
