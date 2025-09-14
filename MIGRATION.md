# Migration to Code Generation (Flutter Compatible)

Dire DI has been updated to support Flutter by replacing `dart:mirrors` with code generation using `injectable` and `get_it`.

## What Changed

### Before (Mirrors-based - NOT Flutter compatible)

```dart
@Service()
class UserService {
  @Autowired()
  late UserRepository userRepository;
}

void main() async {
  final container = DireContainer();
  await container.scan(); // Used mirrors to discover classes
  final service = container.get<UserService>();
}
```

### After (Code Generation - Flutter compatible)

```dart
@Service()
class UserService {
  final UserRepository userRepository;
  UserService(this.userRepository); // Constructor injection
}

void main() async {
  final container = DireContainer();
  await container.configureDependencies(); // Uses generated code
  final service = container.get<UserService>();
}
```

## Migration Steps

### 1. Update Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  dire_di: ^1.0.3
  get_it: ^7.6.4
  injectable: ^2.3.2

dev_dependencies:
  build_runner: ^2.4.7
  injectable_generator: ^2.4.1
```

### 2. Replace Field Injection with Constructor Injection

**Before:**

```dart
@Service()
class UserService {
  @Autowired()
  late UserRepository userRepository;
}
```

**After:**

```dart
@Service()
class UserService {
  final UserRepository userRepository;
  UserService(this.userRepository);
}
```

### 3. Setup Code Generation

Create `lib/injection.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => $initGetIt(getIt);
```

### 4. Run Code Generation

```bash
flutter pub get
flutter pub run build_runner build
```

### 5. Update Main Function

**Before:**

```dart
void main() async {
  final container = DireContainer();
  await container.scan();
  final service = container.get<UserService>();
}
```

**After:**

```dart
import 'injection.dart';

void main() async {
  configureDependencies(); // Initialize generated dependencies
  final service = getIt<UserService>(); // Use getIt directly

  // Or use DireContainer wrapper:
  final container = DireContainer();
  await container.configureDependencies();
  final service = container.get<UserService>();
}
```

## Available Annotations

All original annotations are still available and work the same way:

- `@Service()` - Business logic layer
- `@Repository()` - Data access layer
- `@Controller()` - Presentation layer
- `@Component()` - Generic component
- `@Singleton()` - Single instance (from injectable)
- `@Injectable()` - Factory scope (from injectable)

## Advanced Features

### Named Instances (Qualifiers)

```dart
@Service()
@Named('primary')
class PrimaryUserService implements UserService {}

@Service()
@Named('secondary')
class SecondaryUserService implements UserService {}

// Usage
final primary = getIt<UserService>(instanceName: 'primary');
final secondary = getIt<UserService>(instanceName: 'secondary');
```

### Environment-specific Registration

```dart
@Service()
@Environment('dev')
class DevUserService implements UserService {}

@Service()
@Environment('prod')
class ProdUserService implements UserService {}
```

### Abstract Class Registration

```dart
@Service()
class UserService {}

@Injectable(as: UserService)
class UserServiceImpl extends UserService {}
```

## Benefits of Code Generation Approach

1. **Flutter Compatible** - No dart:mirrors dependency
2. **Better Performance** - No runtime reflection overhead
3. **Compile-time Safety** - Dependency errors caught at build time
4. **Tree Shaking** - Only used dependencies included in final bundle
5. **IDE Support** - Better autocomplete and refactoring

## Backward Compatibility

The old mirrors-based container is still available for non-Flutter projects:

```dart
import 'package:dire_di/src/container/dire_container.dart'; // Legacy version
```

However, we recommend migrating to the code generation approach for all new projects.
