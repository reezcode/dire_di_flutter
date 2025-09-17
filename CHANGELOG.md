## 2.5.0

- Added support for BLoC patterns with part files. The generator now properly handles files using `part of` directives while still allowing main BLoC classes to use dependency injection.
- Improved file filtering to automatically skip generated files (.g.dart, .freezed.dart) and part files during code generation, preventing build errors.
- Enhanced compatibility with AutoRoute by making navigation services injectable through the DI container.
- Fixed "Asset is not a Dart library" errors that occurred when processing part files in larger Flutter projects.
- Better error handling and cleaner build output with reduced warnings.

---

## 2.4.3

- Added DataSource and UseCase annotations

## 2.4.2

- Fixed interface implementation injection bugs

## 2.4.1

- Added static method to get DireContainer via mixin

## 2.4.0

- Simplified initialization with DiCore.initialize() callback support
- Renamed mixins: DireDiMixin to DiCore, DI to DiMixin for better readability
- Improved Flutter widget integration with better error messages and async patterns
- Fixed widget mounting exceptions during async initialization
- Enhanced container lifecycle management for Flutter apps

## 2.3.1

- Renamed DireDiConvenienceMixin to DI for better readability

## 2.3.0

- Added DireDiMixin for easy Flutter StatefulWidget integration
- Automatic container management with sync and async APIs
- Auto-generated convenience properties with DI mixin for direct property access
- Added qualifier support and testing utilities

## 2.2.0

- Added @DireDiEntryPoint annotation for consolidated code generation across multiple files
- Made mirrors-free generation the default for mobile platform compatibility
- Single registerGeneratedDependencies() call for entire project
- Fixed builder conflicts and improved generated code quality
- Renamed builders for clarity: di_mirrors_free_generator to dire_di_generator

## 1.0.0

- Initial release with Spring-like dependency injection for Dart
- Component annotations: @Service, @Repository, @Component, @Controller
- Auto-wiring with @Autowired, @Configuration, @Bean support
- Qualifier, scope, and profile-based conditional registration
- Automatic component scanning and lifecycle management
