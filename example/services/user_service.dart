import 'package:dire_di_flutter/dire_di.dart';
import '../services/database_service.dart';
import '../repositories/user_repository.dart';

@Service()
class UserService {
  final String serviceName;

  @Autowired()
  late UserRepository userRepository;

  UserService(ConfigurationService config)
      : serviceName = 'UserService-${config.environment}';

  void getUserById(String id) {
    print('$serviceName: Getting user $id');
    userRepository.findUser(id);
  }
}