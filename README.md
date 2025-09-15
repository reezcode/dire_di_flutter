# Dire DI Flutter

A Spring-like dependency injection framework for Dart and Flutter with code generation support for mobile platforms.

## Features

- **Spring-like Annotations**: `@Service`, `@Repository`, `@Component`, `@Controller`
- **Auto-wiring**: Automatic dependency resolution using `@Autowired`
- **Code Generation**: Flutter-compatible using build_runner instead of dart:mirrors
- **Consolidated Generation**: `@DireDiEntryPoint` for single-file registration
- **Multi-File Support**: Components spread across multiple files automatically discovered
- **Qualifier Support**: Use `@Qualifier` for specific bean selection
- **Singleton and Prototype Scopes**: Control object lifecycle
- **Conditional Registration**: `@ConditionalOnProperty`, `@ConditionalOnClass`
- **Profile Support**: `@Profile` for environment-specific beans
- **Configuration Classes**: `@Configuration` and `@Bean` for manual setup

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  dire_di_flutter: ^2.0.0

dev_dependencies:
  build_runner: ^2.4.13
```

## Quick Start

### 1. Define Your Services

```dart
import 'package:dire_di/dire_di.dart';

@Service()
class UserService {
  @Autowired()
  UserRepository? userRepository;

  @Autowired()
  EmailService? emailService;

  Future<User> getUser(int id) {
    return userRepository!.findById(id);
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
