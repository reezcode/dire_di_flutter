import 'package:dire_di_flutter/dire_di.dart';
import 'controllers/user_controller.dart';

// Import the generated registration file
import 'app_module.dire_di.dart';

/// Entry point for DI configuration
/// This annotation marks this file as the central point where all
/// DI components from across the project will be consolidated.
@DireDiEntryPoint()
class AppModule {
  // This class serves as the entry point for DI generation
  // All components from the entire project will be registered
  // in the generated file: app_module.dire_di.dart
}

Future<void> main() async {
  print('=== Multi-File Autowired Example ===');
  print('This demonstrates @DireDiEntryPoint with consolidated generation.');
  print('');

  // Initialize the DI container
  final container = DireContainer();

  // Initialize the container and register generated dependencies
  await container.scan();

  // Use the consolidated registration code from all files
  container.registerGeneratedDependencies();

  print('Step 1: All dependencies registered from consolidated generated code...');
  print('Step 2: Components were found in multiple files:');
  print('  - services/database_service.dart (DatabaseService, ConfigurationService)');
  print('  - repositories/user_repository.dart (UserRepository)');
  print('  - services/user_service.dart (UserService)');
  print('  - controllers/user_controller.dart (UserController)');
  print('Step 3: All registered in single file: app_module.dire_di.dart');
  print('');

  print('Step 4: Resolving dependencies with autowired fields...');

  // Get the controller - this will trigger autowiring
  final controller = container.get<UserController>();

  print('Step 5: Using the fully wired components...');
  controller.handleGetUser('123');
}