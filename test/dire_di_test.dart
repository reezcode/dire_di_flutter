import 'package:dire_di/dire_di.dart';
import 'package:test/test.dart';

// Basic service
@Service()
class EmailService {
  String sendEmail(String to, String message) => 'Email sent to $to: $message';
}

// Repository with qualifier
@Repository()
@Qualifier('primary')
class PrimaryUserRepository {
  List<String> getUsers() => ['Alice', 'Bob', 'Charlie'];
}

@Repository()
@Qualifier('secondary')
class SecondaryUserRepository {
  List<String> getUsers() => ['David', 'Eve', 'Frank'];
}

// Service with field injection (nullable fields work better with mirrors)
@Service()
class UserService {
  @Autowired()
  @Qualifier('primary')
  PrimaryUserRepository? primaryRepo;

  @Autowired()
  @Qualifier('secondary')
  SecondaryUserRepository? secondaryRepo;

  @Autowired()
  EmailService? emailService;

  List<String> getAllUsers() {
    final primary = primaryRepo?.getUsers() ?? [];
    final secondary = secondaryRepo?.getUsers() ?? [];
    return [...primary, ...secondary];
  }

  String notifyUser(String user, String message) => emailService?.sendEmail(user, message) ??
        'Email service not available';
}

// Controller that uses the service
@Controller()
class UserController {
  @Autowired()
  UserService? userService;

  void handleRequest() {
    final users = userService?.getAllUsers() ?? [];
    print('Found ${users.length} users: ${users.join(', ')}');

    if (users.isNotEmpty) {
      final notification = userService?.notifyUser(users.first, 'Welcome!');
      print('Notification result: $notification');
    }
  }
}

// Configuration with bean methods
@Configuration()
class AppConfig {
  @Bean()
  @Singleton()
  Map<String, String> createConfig() => {
      'app.name': 'Dire DI Demo',
      'app.version': '1.0.0',
      'feature.enabled': 'true',
    };

  @Bean()
  @Qualifier('logger')
  Logger createLogger() => Logger('DireApp');
}

class Logger {

  Logger(this.name);
  final String name;

  void info(String message) {
    print('[$name] INFO: $message');
  }
}

// Profile-specific services
@Service()
@Profile('development')
class DevNotificationService {
  String notify(String message) => 'DEV: $message';
}

@Service()
@Profile('production')
class ProdNotificationService {
  String notify(String message) => 'PROD: $message';
}

void main() {
  group('Dire DI Framework Tests', () {
    late DireContainer container;

    setUpAll(() async {
      container = DireContainer(
        activeProfiles: ['development'],
        properties: {
          'feature.enabled': 'true',
          'app.env': 'development',
        },
      );

      await container.scan();
    });

    tearDownAll(() {
      container.destroy();
    });

    test('should initialize container successfully', () {
      expect(container.contains<EmailService>(), isTrue);
    });

    test('should register basic services', () {
      expect(container.contains<EmailService>(), isTrue);
    });

    test('should inject basic service dependencies', () {
      final emailService = container.get<EmailService>();
      final result = emailService.sendEmail('test@example.com', 'Hello!');
      expect(result, equals('Email sent to test@example.com: Hello!'));
    });

    test('should handle qualified repositories', () {
      final primaryRepo = container.get<PrimaryUserRepository>('primary');
      final secondaryRepo = container.get<SecondaryUserRepository>('secondary');

      expect(primaryRepo.getUsers(), equals(['Alice', 'Bob', 'Charlie']));
      expect(secondaryRepo.getUsers(), equals(['David', 'Eve', 'Frank']));
    });

    test('should inject complex service dependencies', () {
      final userService = container.get<UserService>();
      final allUsers = userService.getAllUsers();

      expect(allUsers.length, equals(6));
      expect(allUsers,
          containsAll(['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank']),);
    });

    test('should inject controller dependencies', () {
      final controller = container.get<UserController>();
      expect(controller.userService, isNotNull);
    });

    test('should create configuration beans', () {
      final config = container.get<Map<String, String>>();
      expect(config['app.name'], equals('Dire DI Demo'));
      expect(config['app.version'], equals('1.0.0'));
      expect(config['feature.enabled'], equals('true'));
    });

    test('should handle qualified configuration beans', () {
      final logger = container.getByName('logger') as Logger;
      expect(logger.name, equals('DireApp'));
    });

    test('should respect active profiles', () {
      expect(container.contains<DevNotificationService>(), isTrue);
      expect(container.contains<ProdNotificationService>(), isFalse);

      final devService = container.get<DevNotificationService>();
      final result = devService.notify('Test message');
      expect(result, equals('DEV: Test message'));
    });

    test('should provide bean introspection', () {
      // Check for specific service types instead of Object
      final emailServices = container.getBeanNames<EmailService>();
      final userServices = container.getBeanNames<UserService>();
      expect(emailServices.length + userServices.length, greaterThan(0));
    });

    test('should handle email service through user service', () {
      final userService = container.get<UserService>();
      final result = userService.notifyUser('alice@test.com', 'Welcome!');
      expect(result, equals('Email sent to alice@test.com: Welcome!'));
    });
  });

  group('Profile Tests', () {
    test('should work with production profile', () async {
      final prodContainer = DireContainer(activeProfiles: ['production']);
      await prodContainer.scan();

      expect(prodContainer.contains<ProdNotificationService>(), isTrue);
      expect(prodContainer.contains<DevNotificationService>(), isFalse);

      final prodService = prodContainer.get<ProdNotificationService>();
      final result = prodService.notify('Production test');
      expect(result, equals('PROD: Production test'));

      prodContainer.destroy();
    });
  });

  group('Exception Tests', () {
    test('should throw when bean not found', () async {
      final testContainer = DireContainer();
      await testContainer.scan(); // Initialize the container first

      expect(() => testContainer.get<DateTime>(),
          throwsA(isA<BeanNotFoundException>()),);

      testContainer.destroy();
    });
  });
}
