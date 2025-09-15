import 'package:dire_di_flutter/dire_di.dart';

import '../services/database_service.dart';

@Repository()
class UserRepository {
  @Autowired()
  late DatabaseService databaseService;

  @Autowired()
  late ConfigurationService configService;

  void findUser(String id) {
    databaseService.connect();
    final connectionString = configService.getConnectionString();
    print('UserRepository: Using connection: $connectionString');
    databaseService.query('SELECT * FROM users WHERE id = $id');
  }
}
