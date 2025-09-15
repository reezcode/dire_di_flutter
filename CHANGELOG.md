## 2.2.0

### 🎉 Major Features

- **Consolidated Code Generation**: New `@DireDiEntryPoint` annotation allows consolidating all DI registrations into a single file
- **Multi-File Support**: Components can now be spread across multiple files and automatically discovered
- **Single Registration Call**: `registerGeneratedDependencies()` only needs to be called once from the entry point
- **Aggregating Builder**: New builder scans entire project and generates consolidated registration code
- **Improved Developer Experience**: No more managing multiple `.dire_di.dart` files

### 🚀 Mobile Platform Support

- **Mirrors-Free by Default**: Main `dire_di_generator` is now mirrors-free and mobile compatible
- **Flutter/Android/iOS Compatible**: Generated code runs on all Flutter platforms without restrictions
- **Build-Time Only Dependencies**: Code analysis happens only during build, not at runtime
- **Single Builder**: Eliminated builder conflicts - only one active builder by default

### 🔧 Technical Improvements

- **Renamed Builders**: Main builder is now `dire_di_generator` (was `di_mirrors_free_generator`)
- **Conflict Resolution**: Fixed "Potential outputs must be unique" error by making legacy builders opt-in only
- Added `MirrorsFreeAggregatingBuilder` for mobile platform compatibility
- Enhanced import path resolution for better generated code
- Improved dependency ordering in generated registrations
- Better error handling and logging during code generation

### 🚨 Breaking Changes

- **Builder Names**: Main builder renamed from `di_mirrors_free_generator` to `dire_di_generator`
- **Auto-Apply**: Legacy `di_generator` is now opt-in only (`auto_apply: none`)
- **Default Behavior**: Package now uses mirrors-free generation by default

### 📚 Documentation

- Updated examples to demonstrate multi-file usage
- Added comprehensive documentation for `@DireDiEntryPoint`
- Improved README with new usage patterns
- Added explanation of mirrors-free approach for mobile platforms
- Added explanation of mirrors-free approach for mobile platforms

### 🚀 Migration Guide

**Before (multiple files):**

```dart
// Each file had its own .dire_di.dart
import 'service1.dire_di.dart';
import 'service2.dire_di.dart';

container.registerGeneratedDependencies(); // Multiple calls needed
```

**After (consolidated):**

```dart
@DireDiEntryPoint()
class AppModule {}

import 'app_module.dire_di.dart';
container.registerGeneratedDependencies(); // Single call!
```

### 📱 Mobile Platform Notes

This package now fully supports Android/iOS through mirrors-free code generation. The `dart:mirrors` dependency only exists during build time for legacy builders. The default `di_mirrors_free_generator` produces code that runs without any mirrors dependency on mobile platforms.

---

## 2.2.0

- Spring-like dependency injection for Dart
- Auto-wiring with @Autowired annotation
- Component annotations: @Service, @Repository, @Component, @Controller
- Configuration support with @Configuration and @Bean
- Qualifier support for disambiguation
- Singleton and Prototype scopes
- Profile-based conditional registration
- Property and class-based conditionals
- Automatic component scanning using dart:mirrors
- Field injection support
- Constructor injection support
- Circular dependency detection
- Bean lifecycle management
