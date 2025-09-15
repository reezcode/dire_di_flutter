import 'package:dire_di_flutter/dire_di.dart';

import '../services/database_service.dart';
import 'user_repository.dart';

@Repository()
class UserRepositoryImpl implements UserRepository {
  @Autowired()
  late DatabaseService databaseService;

  @Autowired()
  late ConfigurationService configService;

  @override
  void findUser(String id) {
    databaseService.connect();
    final connectionString = configService.getConnectionString();
    print('UserRepository: Using connection: $connectionString');
    databaseService.query('SELECT * FROM users WHERE id = $id');
  }
}
