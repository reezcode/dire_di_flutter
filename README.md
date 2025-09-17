# Dire DI Flutter

A Spring-like dependency injection framework for Dart and Flutter with code generation support for mobile platforms.

## Features

- **Spring-like Annotations**: `@Service`, `@Repository`, `@Component`, `@Controller`, `@DataSource`, `@UseCase`
- **Constructor Injection**: Modern dependency injection via constructors (recommended)
- **Code Generation**: Flutter-compatible using build_runner instead of dart:mirrors
- **Consolidated Generation**: `@DireDiEntryPoint` for single-file registration
- **Multi-File Support**: Components spread across multiple files automatically discovered
- **BLoC Pattern Support**: Full compatibility with part files for state management
- **AutoRoute Integration**: Built-in router service for type-safe navigation
- **Flutter Mixin**: Easy integration with StatefulWidget via `DiCore` and `DiMixin`
- **Qualifier Support**: Use named instances for specific bean selection
- **Singleton and Prototype Scopes**: Control object lifecycle
- **Conditional Registration**: `@ConditionalOnProperty`, `@ConditionalOnClass`
- **Profile Support**: `@Profile` for environment-specific beans
- **Configuration Classes**: `@Configuration` and `@Bean` for manual setup
- **Smart File Processing**: Automatic filtering of generated and part files

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dire_di_flutter: ^2.5.0

dev_dependencies:
  build_runner: ^2.4.13
```

## Quick Start

### 1. Define Your Services (Constructor Injection - Recommended)

```dart
import 'package:dire_di/dire_di.dart';

@Service()
class UserService {
  final UserRepository userRepository;
  final EmailService emailService;

  UserService(this.userRepository, this.emailService);

  Future<User> getUser(int id) {
    return userRepository.findById(id);
  }
}

@Repository()
class UserRepository {
  Future<User> findById(int id) async {
    // Database access logic here
    return User(id: id, name: 'John Doe');
  }
}

@Service()
class EmailService {
  void sendEmail(String to, String subject, String body) {
    print('Sending email to $to: $subject');
  }
}
```

### 2. Initialize the Container

```dart
void main() async {
  final container = DireContainer();
  await container.scan(); // Auto-discover and register components

  final userService = container.get<UserService>();
  final user = await userService.getUser(1);

  print('User: ${user.name}');
}
```

### 3. Run Code Generation

```bash
dart pub run build_runner build
```

> **Note**: The package uses the `dire_di_generator` builder by default, which is mirrors-free and mobile-compatible. Legacy builders are available as opt-in only to avoid conflicts.

## Consolidated Generation (New in v2.0.0)

For larger projects with components spread across multiple files, use `@DireDiEntryPoint` to consolidate all registrations into a single file:

### 1. Create an Entry Point

```dart
// app_module.dart
import 'package:dire_di_flutter/dire_di.dart';
import 'app_module.dire_di.dart'; // Generated file

@DireDiEntryPoint()
class AppModule {
  // Entry point for DI configuration
}
```

### 2. Spread Components Across Files

```dart
// services/user_service.dart
@Service()
class UserService {
  @Autowired()
  late UserRepository userRepository;
}

// repositories/user_repository.dart
@Repository()
class UserRepository {
  // Implementation
}

// controllers/user_controller.dart
@Controller()
class UserController {
  @Autowired()
  late UserService userService;
}
```

### 3. Single Registration Call

```dart
void main() async {
  final container = DireContainer();
  await container.scan();

  // All components from across the project registered with one call!
  container.registerGeneratedDependencies();

  final controller = container.get<UserController>();
}
```

**Benefits:**

- ✅ Only one `registerGeneratedDependencies()` call needed
- ✅ Components automatically discovered across all files
- ✅ Single consolidated `.dire_di.dart` file generated
- ✅ Proper dependency ordering maintained
- ✅ Better organization for large projects

## Flutter Integration with DiCore

For easier Flutter integration, use the `DiCore` mixin with your StatefulWidget states:

### ⚠️ Important: Async Initialization Required

**The DI container initialization is asynchronous**. You must handle this properly to avoid exceptions:

### Option 1: Pre-initialize in main() (Recommended)

```dart
import 'package:flutter/material.dart';
import 'package:dire_di_flutter/dire_di.dart';
import 'app_module.dire_di.dart'; // Your generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Pre-initialize DI container before runApp()
  await DiCore.initialize();

  // Register generated dependencies
  final container = DireContainer();
  await container.scan();
  container.registerGeneratedDependencies();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with DiCore, DiMixin {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
```

### Option 2: Async Pattern in Widgets

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with DiCore, DiMixin {
  UserService? userService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
  }

  void _loadDependencies() async {
    try {
      // Use convenience properties from DiMixin (recommended)
      userService = await userServiceAsync;

      // Or use direct async access:
      // userService = await getAsync<UserService>();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('DI Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Text('User: ${userService?.getCurrentUser() ?? "None"}'),
      ),
    );
  }
}
```

### ❌ Common Mistakes to Avoid

```dart
// DON'T DO THIS - Will cause exceptions
class _BadExampleState extends State<BadExample> with DiCore {
  late UserService userService;

  @override
  void initState() {
    super.initState();
    userService = get<UserService>(); // ❌ This will throw!
  }
}

// ✅ DO THIS INSTEAD
class _GoodExampleState extends State<GoodExample> with DiCore, DiMixin {
  UserService? userService;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    userService = await userServiceAsync; // ✅ Safe async access
    setState(() {});
  }
}
```

### DiMixin Convenience Properties

When you use `DiMixin`, you get auto-generated convenience properties for all your dependencies:

```dart
class _MyWidgetState extends State<MyWidget> with DiCore, DiMixin {
  void someMethod() async {
    // Auto-generated properties from DiMixin:
    final user = await userServiceAsync;
    final repo = await userRepositoryAsync;
    final controller = await userControllerAsync;

    // These are equivalent to:
    // final user = await getAsync<UserService>();
  }
}
```

### Mixin API

```dart
// Async methods (recommended - auto-initialize container)
final service = await getAsync<UserService>();
final namedService = await getAsync<ApiClient>('prod');
final hasService = await hasAsync<UserService>();
final allServices = await getAllAsync<UserService>();

// Sync methods (container must be pre-initialized)
final service = get<UserService>();
final namedService = get<ApiClient>('prod');
final hasService = has<UserService>();
final allServices = getAll<UserService>();

// Manual registration
await register<ApiClient>(() => ApiClient(baseUrl: 'https://api.example.com'));

// Container management
await DireDiMixin.initialize(); // Pre-initialize
DireDiMixin.reset(); // Reset for testing
```

### Benefits of DireDiMixin

- ✅ **No Manual Container Management**: Automatic DireContainer setup
- ✅ **Global Container**: Single instance shared across all widgets
- ✅ **Sync and Async Support**: Choose based on your initialization needs
- ✅ **Type Safety**: Full generic type support with compile-time checking
- ✅ **Qualifier Support**: Named instances via `get<T>('name')`
- ✅ **Convenient Methods**: `has<T>()`, `getAll<T>()`, `register<T>()`
- ✅ **Flutter Optimized**: Designed specifically for StatefulWidget states

## Auto-Generated Convenience Properties

For even easier access, the generated `.dire_di.dart` file includes a `DI` mixin with direct property access:

### Direct Property Access

```dart
class _MyWidgetState extends State<MyWidget> with DireDiMixin, DI {
  @override
  Widget build(BuildContext context) {
    // Direct property access - no get<T>() calls needed!
    return Column(
      children: [
        Text('User: ${userService.getCurrentUser()}'),
        Text('Database: ${databaseService.isConnected()}'),
        Text('Config: ${configurationService.getConfigValue('app.name')}'),
      ],
    );
  }

  void updateUser() {
    // Direct controller access
    userController.updateUser('New Name');
  }
}
```

### Async Property Access

```dart
class _AsyncWidgetState extends State<AsyncWidget> with DireDiMixin, DI {
  String? data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Async properties ensure safe initialization
    final svc = await userServiceAsync;
    final db = await databaseServiceAsync;

    setState(() {
      data = '${svc.getCurrentUser()} from ${db.getDatabaseUrl()}';
    });
  }
}
```

### Auto-Generated Properties

For each `@Service()`, `@Repository()`, `@Component()`, etc., the generator creates:

```dart
// If you have UserService, you get:
UserService get userService;
Future<UserService> get userServiceAsync;

// If you have DatabaseService, you get:
DatabaseService get databaseService;
Future<DatabaseService> get databaseServiceAsync;

// And so on for all your components...
```

### Benefits of Convenience Properties

- ✅ **Zero Boilerplate**: No manual property definitions
- ✅ **Direct Access**: `userService` instead of `get<UserService>()`
- ✅ **Type Safe**: Full compile-time type checking
- ✅ **IDE Friendly**: Auto-completion and refactoring support
- ✅ **Auto-Generated**: Automatically updated when you add/remove services
- ✅ **Clean Code**: Eliminates DI syntax completely from UI code

## Mobile Platform Support

This package fully supports **Android, iOS, and all Flutter platforms** through mirrors-free code generation.

### Why No dart:mirrors Issues?

Unlike some DI packages, `dire_di_flutter` uses **code generation** instead of runtime reflection:

- **Build Time**: Code analysis happens during `dart pub run build_runner build`
- **Runtime**: Generated code contains zero mirrors dependency
- **Mobile Compatible**: Works on all Flutter platforms without restrictions

### How It Works

```dart
// 1. Your annotated classes (any platform)
@Service()
class UserService { ... }

// 2. Code generation creates (mirrors-free)
extension GeneratedDependencies on DireContainer {
  void registerGeneratedDependencies() {
    register<UserService>(() => UserService());
  }
}

// 3. Your app uses plain Dart code (any platform)
container.registerGeneratedDependencies(); // ✅ Works everywhere
```

**The Magic**: The build process uses advanced static analysis (not mirrors) to discover your components and generates plain Dart registration code that runs anywhere Flutter does.

## Advanced Usage

### BLoC with Part Files

The framework supports BLoC patterns that use part files for states and events:

```dart
// user_bloc.dart - Main file with DI annotation
@Controller()
class UserBloc extends Bloc<UserEvent, UserState> {
  @Autowired()
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial());
}

// user_state.dart - Part file (automatically skipped)
part of 'user_bloc.dart';

class UserState {}

// user_event.dart - Part file (automatically skipped)
part of 'user_bloc.dart';

class UserEvent {}
```

### AutoRoute Integration

Make navigation services injectable:

```dart
@Service()
class RouterService {
  final AppRouter _router = AppRouter();

  AppRouter get router => _router;

  void navigateToHome() => _router.push(const HomeRoute());
}
```

### Qualifiers

When you have multiple implementations:

```dart
@Service()
@Qualifier('primary')
class PrimaryUserService implements UserService {}

@Service()
@Qualifier('secondary')
class SecondaryUserService implements UserService {}

// Inject specific implementation
@Autowired()
@Qualifier('primary')
UserService primaryService;
```

### Configuration Classes

```dart
@Configuration()
class AppConfig {
  @Bean()
  Database createDatabase() {
    return Database(connectionString: 'sqlite://app.db');
  }
}
```

### Profiles

```dart
@Service()
@Profile('development')
class DevEmailService implements EmailService {}

@Service()
@Profile('production')
class ProdEmailService implements EmailService {}
```

// Only registered if sqflite package is available
}

````

## Troubleshooting

### Common Issues and Solutions

#### 1. Build Errors with Part Files

**Problem**: Getting "Asset is not a Dart library" errors during build.

**Solution**: Dire DI automatically excludes part files and generated files. Ensure your part files are properly declared:

```dart
// ✅ Correct - Part file properly excluded
part of 'user_bloc.dart';

// ❌ Incorrect - Missing part declaration
// This file will be processed and may cause errors
````

#### 2. BLoC with Part Files Not Injecting

**Problem**: BLoC using part files for states/events isn't being registered.

**Solution**: Keep DI annotations in the main BLoC file, not part files:

```dart
// user_bloc.dart - Main file with DI annotations
@Controller()  // ✅ Annotation here
class UserBloc extends Bloc<UserEvent, UserState> {
  @Autowired()
  final UserRepository repository;
}

// user_state.dart - Part file (no annotations needed)
part of 'user_bloc.dart';
// ✅ Just part file content, no DI annotations
```

#### 3. Generated Files Causing Build Issues

**Problem**: Code generation conflicts with Dire DI processing.

**Solution**: Run build commands in the correct order:

```bash
# Clean first
flutter packages pub run build_runner clean

# Generate Dire DI files
flutter packages pub run build_runner build --filter="dire_di"

# Then generate other files (freezed, json, etc.)
flutter packages pub run build_runner build
```

#### 4. AutoRoute Not Working with DI

**Problem**: Navigation not working after DI integration.

**Solution**: Ensure RouterService is properly configured and injected:

```dart
// ✅ Register RouterService as singleton
@Service()
class RouterService {
  static final _instance = AppRouter();
  AppRouter get router => _instance;
}

// ✅ Use RouterService in MaterialApp
final routerService = get<RouterService>();
MaterialApp.router(routerConfig: routerService.router.config())
```

## Comparison with Other DI Solutions

### vs get_it + injectable

**get_it + injectable:**

```dart
@injectable
class UserService {
  UserService(this.userRepository);
  final UserRepository userRepository;
}

// Need manual to direct access
// Hard to read
```

**dire_di_flutter:**

```dart
@Service()
class UserService {
  @Autowired()
  late UserRepository userRepository; // Field injection!
}

// Direct access via mixin
// Spring-like annotations
```

### Key Advantages

1. Spring-like field injection with @Autowired annotation
2. Code generation for mobile platform compatibility (no dart:mirrors at runtime)
3. Automatic component scanning and discovery
4. Spring-familiar annotations (@Service, @Repository, @Controller)
5. Rich conditional and profile support
6. Flutter integration via DiCore and DiMixin

## Troubleshooting

### Part Files Build Errors

If you get "Asset is not a Dart library" errors, ensure part files have proper declarations:

```dart
part of 'user_bloc.dart'; // Required at top of part files
```

### BLoC Not Being Injected

Keep DI annotations in the main BLoC file, not in part files:

```dart
@Controller() // In main user_bloc.dart file
class UserBloc extends Bloc<UserEvent, UserState> {}
```

### Build Order Issues

Run code generation in this order:

```bash
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --filter="dire_di"
flutter packages pub run build_runner build
```

## API Reference

### Core Annotations

- `@Component()` - Base component
- `@Service()` - Service layer
- `@Repository()` - Data access layer
- `@Controller()` - Presentation layer
- `@DataSource()` - Data source layer
- `@UseCase()` - Use case layer
- `@Autowired()` - Dependency injection
- `@Qualifier(name)` - Bean qualification
- `@Singleton()` - Single instance
- `@Configuration()` - Config classes
- `@Bean()` - Factory methods

### Container Methods

```dart
final container = DireContainer();
await container.scan();

final service = container.get<UserService>();
bool exists = container.contains<UserService>();
container.register<UserService>(() => UserService());
```

## Best Practices

1. Use specific annotations like `@Service`, `@Repository` over `@Component`
2. Add `@Qualifier` when you have multiple implementations
3. Use `@Profile` for environment-specific configurations
4. Use constructor injection when possible, field injection with @Autowired for convenience
5. Pre-initialize DI container in main() for Flutter apps

## Contributing

Contributions welcome! Please submit a Pull Request.

## License

MIT License - see LICENSE file for details.
