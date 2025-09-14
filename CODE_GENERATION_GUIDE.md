# Dire DI - Code Generation Workflow Documentation

## Overview

Dire DI has been successfully migrated from using `dart:mirrors` to a build-time code generation approach using `build_runner`. This makes it **Flutter-compatible** while maintaining the familiar Spring-like API.

## Key Features

✅ **Flutter Compatible** - No dart:mirrors dependency  
✅ **Spring-like Annotations** - @Service, @Repository, @Controller, @Autowired  
✅ **Constructor Injection** - Automatic dependency resolution  
✅ **Field Injection** - @Autowired fields with late initialization  
✅ **Qualifier Support** - Named dependencies with @Qualifier  
✅ **Scope Management** - Singleton and prototype scopes  
✅ **Same API** - Original DireContainer interface preserved

## Migration Summary

### Before (mirrors-based):

```dart
// Used dart:mirrors for runtime reflection
import 'dart:mirrors';

// Runtime dependency discovery
final mirror = reflectClass(SomeService);
```

### After (code generation):

```dart
// Build-time code generation with build_runner
// Generated code handles all dependency injection
extension GeneratedDependencies on DireContainer {
  void registerGeneratedDependencies() {
    // Generated registration code...
  }
}
```

## Code Generation Workflow

### 1. Annotate Your Classes

```dart
@Service()
class UserService {
  final ConfigService config;

  @Autowired()
  late DatabaseService database;

  UserService(this.config);

  void getUser(String id) {
    database.query('SELECT * FROM users WHERE id = ?', [id]);
  }
}

@Repository()
class DatabaseService {
  void query(String sql, List<dynamic> params) {
    print('Executing: $sql with $params');
  }
}

@Service()
class ConfigService {
  String get dbUrl => 'localhost:5432';
}
```

### 2. Run Build Runner

```bash
dart run build_runner build
```

### 3. Generated Code (Example)

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
extension GeneratedDependencies on DireContainer {
  void registerGeneratedDependencies() {
    // Register ConfigService
    register<ConfigService>(
      () => ConfigService(),
      scope: ScopeType.singleton,
    );

    // Register DatabaseService
    register<DatabaseService>(
      () => DatabaseService(),
      scope: ScopeType.singleton,
    );

    // Register UserService with mixed injection
    register<UserService>(
      () {
        // Constructor injection
        final instance = UserService(get<ConfigService>());
        // Autowired field injection
        instance.database = get<DatabaseService>();
        return instance;
      },
      scope: ScopeType.singleton,
    );
  }
}
```

### 4. Use Your Services

```dart
void main() {
  final container = DireContainer();
  container.scan(); // Calls registerGeneratedDependencies()

  final userService = container.get<UserService>();
  userService.getUser('123');
}
```

## Architecture

### Core Components

1. **DireContainer** - Main DI container (same API as before)
2. **DiGenerator** - Code generator that scans annotations
3. **Annotations** - @Service, @Repository, @Controller, @Autowired, etc.
4. **Build System** - Integration with build_runner

### Generated Code Pattern

The generator creates registration code that handles:

- **Constructor injection** - Dependencies passed to constructor
- **Field injection** - @Autowired fields set after instantiation
- **Qualifiers** - Named dependencies with @Qualifier
- **Scopes** - Singleton vs prototype scope management

### Example Flow

```
Source Code with Annotations
           ↓
    DiGenerator (build_runner)
           ↓
    Generated Registration Code
           ↓
    DireContainer.scan() calls generated code
           ↓
    All dependencies registered and ready
```

## Advanced Features

### Qualifier Support

```dart
@Service('userCache')
class UserCacheService { }

@Service('systemCache')
class SystemCacheService { }

@Controller()
class UserController {
  @Autowired()
  @Qualifier('userCache')
  late UserCacheService cache;
}
```

### Mixed Injection Patterns

```dart
@Service()
class ComplexService {
  final ConfigService config;     // Constructor injection

  @Autowired()
  late DatabaseService database;  // Field injection

  @Autowired()
  @Qualifier('redis')
  late CacheService cache;        // Field injection with qualifier

  ComplexService(this.config);
}
```

### Conditional Registration

```dart
@Service()
@Profile('development')
class DevDatabaseService implements DatabaseService { }

@Service()
@Profile('production')
class ProdDatabaseService implements DatabaseService { }
```

## Comparison: Original vs Generated

### Original Container API (Preserved)

```dart
final container = DireContainer();
container.scan();                    // Same method
final service = container.get<T>();  // Same method
container.register<T>(() => T());    // Same method
```

### Internal Implementation Changes

- **Before**: Used dart:mirrors for runtime reflection
- **After**: Uses generated registration code
- **Result**: Same API, Flutter compatible, better performance

## Benefits of Migration

1. **Flutter Compatibility** - No more dart:mirrors limitations
2. **Better Performance** - Build-time vs runtime dependency resolution
3. **Tree Shaking** - Only used dependencies included in final build
4. **Static Analysis** - Compile-time dependency validation
5. **Familiar API** - No changes to existing code using the container

## Files Updated in Migration

### Core Files

- `lib/src/container/dire_container.dart` - Removed mirrors, kept API
- `lib/src/generator/di_generator.dart` - New code generator
- `lib/builder.dart` - Build system integration
- `pubspec.yaml` - Updated dependencies

### Utility Files

- `lib/src/utils/type_utils.dart` - Removed mirrors dependencies
- `lib/src/core/injection_context.dart` - Updated for generated approach
- All annotation files - Updated for code generation compatibility

The migration successfully preserves the user-friendly Spring-like DI experience while making the framework Flutter-ready through modern build-time code generation.
