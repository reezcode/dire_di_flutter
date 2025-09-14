import 'package:dire_di/dire_di.dart';

// Import the generated registration file
import 'autowired_example.dire_di.dart';

// Basic service with no dependencies
@Service()
class DatabaseService {
  void connect() {
    print('DatabaseService: Connected to database');
  }

  void query(String sql) {
    print('DatabaseService: Executing query: $sql');
  }
}

// Service with constructor injection
@Service()
class ConfigurationService {
  ConfigurationService() : environment = 'development';
  final String environment;

  String getConnectionString() =>
      'jdbc:mysql://localhost:3306/mydb?env=$environment';
}

// Repository with autowired fields
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

// Service with both constructor injection and autowired fields
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

// Controller with autowired service
@Controller()
class UserController {
  @Autowired()
  late UserService userService;

  void handleGetUser(String id) {
    print('UserController: Handling request for user $id');
    userService.getUserById(id);
  }
}

Future<void> main() async {
  print('=== Autowired Example ===');
  print('This demonstrates @Autowired field injection with code generation.');
  print('');

  // Initialize the DI container
  final container = DireContainer();

  // Initialize the container and register generated dependencies
  await container.scan();

  // Use the generated registration code
  container.registerGeneratedDependencies();

  print('Step 1: Dependencies registered from generated code...');
  print('Step 2: Resolving dependencies with autowired fields...');

  // Get the controller - this will trigger autowiring
  final controller = container.get<UserController>();

  print('Step 3: Using the fully wired components...');
  controller.handleGetUser('123');
}
