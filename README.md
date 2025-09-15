# Dire DI Flutter

A Spring-like dependency injection framework for Dart and Flutter with code generation support for mobile platforms.

## Features

- **Spring-like Annotations**: `@Service`, `@Repository`, `@Component`, `@Controller`
- **Constructor Injection**: Modern dependency injection via constructors (recommended)
- **Code Generation**: Flutter-compatible using build_runner instead of dart:mirrors
- **Consolidated Generation**: `@DireDiEntryPoint` for single-file registration
- **Multi-File Support**: Components spread across multiple files automatically discovered
- **Flutter Mixin**: Easy integration with StatefulWidget via `DireDiMixin`
- **Qualifier Support**: Use named instances for specific bean selection
- **Singleton and Prototype Scopes**: Control object lifecycle
- **Conditional Registration**: `@ConditionalOnProperty`, `@ConditionalOnClass`
- **Profile Support**: `@Profile` for environment-specific beans
- **Configuration Classes**: `@Configuration` and `@Bean` for manual setup

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dire_di_flutter: ^2.4.0

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

class \_HomePageState extends State<HomePage> with DireDiMixin {
String? currentUser;
bool isLoading = true;

@override
void initState() {
super.initState();
\_loadData();
}

Future<void> \_loadData() async {
try {
// Get dependencies asynchronously (auto-initializes if needed)
final userService = await getAsync<UserService>();

      setState(() {
        currentUser = userService.getCurrentUser();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }

}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('User Info')),
body: isLoading
? CircularProgressIndicator()
: Text('Current User: $currentUser'),
);
}
}

````

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
````

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

### Qualifiers

When you have multiple implementations of the same interface:

```dart
@Service()
@Qualifier('primary')
class PrimaryUserService implements UserService {
  // Implementation
}

@Service()
@Qualifier('secondary')
class SecondaryUserService implements UserService {
  // Implementation
}

@Component()
class UserController {
  @Autowired()
  @Qualifier('primary')
  UserService? userService;
}
```

### Configuration Classes

For complex bean setup:

```dart
@Configuration()
class DatabaseConfig {
  @Bean()
  @Singleton()
  Database createDatabase() {
    return Database(connectionString: Environment.dbUrl);
  }

  @Bean()
  @Qualifier('cache')
  Cache createCache() {
    return RedisCache();
  }
}
```

### Profiles

Environment-specific configurations:

```dart
@Service()
@Profile('development')
class DevEmailService implements EmailService {
  void sendEmail(String to, String subject, String body) {
    print('DEV: Sending email to $to: $subject');
  }
}

@Service()
@Profile('production')
class ProdEmailService implements EmailService {
  void sendEmail(String to, String subject, String body) {
    // Real email sending logic
  }
}

// Set active profiles
final container = DireContainer(activeProfiles: ['development']);
```

### Conditional Beans

Register beans based on conditions:

```dart
@Service()
@ConditionalOnProperty(
  name: 'feature.email.enabled',
  havingValue: 'true'
)
class EmailService {
  // Only registered if feature.email.enabled=true
}

@Service()
@ConditionalOnClass('package:sqflite/sqflite.dart')
class SQLiteUserRepository implements UserRepository {
  // Only registered if sqflite package is available
}
```

## Important Note about Field Types

Due to Dart's mirror system limitations, `late` fields may not work properly with dependency injection. Use nullable fields instead:

```dart
// ❌ Problematic with mirrors
@Service()
class MyService {
  @Autowired()
  late UserRepository repository;
}

// ✅ Recommended approach
@Service()
class MyService {
  @Autowired()
  UserRepository? repository;
}
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

// Requires build_runner
// No field injection
// Manual registration often needed
```

**dire_di:**

```dart
@Service()
class UserService {
  @Autowired()
  late UserRepository userRepository; // Field injection!
}

// No build_runner needed
// Spring-like annotations
// Auto-discovery with reflection
```

### Key Advantages

1. **No Code Generation**: Uses mirrors for runtime reflection
2. **Field Injection**: Direct field injection like Spring
3. **Auto-Discovery**: Automatic component scanning
4. **Spring Familiarity**: Same annotations as Spring Framework
5. **Rich Conditional Support**: Extensive conditional registration
6. **Profile Management**: Environment-specific configurations

## API Reference

### Annotations

- `@Component()` - Base component annotation
- `@Service()` - Service layer components
- `@Repository()` - Data access layer components
- `@Controller()` - Presentation layer components
- `@Configuration()` - Configuration classes
- `@Bean()` - Bean factory methods
- `@Autowired()` - Dependency injection marker
- `@Qualifier(name)` - Bean qualification
- `@Singleton()` - Singleton scope
- `@Prototype()` - Prototype scope
- `@Profile(profiles)` - Profile-specific beans
- `@ConditionalOnProperty()` - Property-based conditions
- `@ConditionalOnClass()` - Class-based conditions

### Container Methods

```dart
final container = DireContainer();

// Initialize
await container.scan();

// Get beans
final service = container.get<UserService>();
final qualifiedService = container.get<UserService>('qualifier');

// Check existence
bool exists = container.contains<UserService>();

// Get all instances
List<UserService> services = container.getAll<UserService>();

// Manual registration
container.register<UserService>(() => UserService());
container.registerInstance<UserService>(userServiceInstance);
```

## Best Practices

1. **Use Specific Annotations**: Prefer `@Service`, `@Repository` over generic `@Component`
2. **Qualify Multiple Implementations**: Use `@Qualifier` when you have multiple beans of same type
3. **Profile Organization**: Group environment-specific beans with `@Profile`
4. **Lazy Initialization**: Use prototype scope for heavy objects when appropriate
5. **Constructor vs Field Injection**: Field injection is simpler, constructor injection is more testable

## Limitations

1. **Mirrors Dependency**: Requires dart:mirrors (not available in Flutter web)
2. **Runtime Overhead**: Reflection has performance cost compared to code generation
3. **Tree Shaking**: May prevent dead code elimination in some cases

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
