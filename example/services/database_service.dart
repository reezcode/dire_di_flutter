import 'package:dire_di_flutter/dire_di.dart';

@Service()
class DatabaseService {
  void connect() {
    print('DatabaseService: Connected to database');
  }

  void query(String sql) {
    print('DatabaseService: Executing query: $sql');
  }
}

@Service()
class ConfigurationService {
  ConfigurationService() : environment = 'development';
  final String environment;

  String getConnectionString() =>
      'jdbc:mysql://localhost:3306/mydb?env=$environment';
}
