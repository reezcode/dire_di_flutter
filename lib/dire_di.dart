/// # Dire DI - Spring-like Dependency Injection for Dart
///
/// A powerful dependency injection framework that brings Spring-like features to Dart,
/// with Flutter compatibility using code generation instead of dart:mirrors.
///
/// ## Features
///
/// - **Spring-like Annotations**: `@Service`, `@Repository`, `@Component`, `@Controller`
/// - **Constructor Injection**: Automatic dependency resolution via constructors
/// - **Qualifier Support**: Use named instances for specific bean selection
/// - **Singleton and Prototype Scopes**: Control object lifecycle
/// - **Conditional Registration**: `@ConditionalOnProperty`, `@ConditionalOnClass`
/// - **Profile Support**: `@Profile` for environment-specific beans
/// - **Configuration Classes**: `@Configuration` and `@Bean` for manual setup
/// - **Flutter Compatible**: Uses code generation instead of dart:mirrors
/// - **Same API**: Maintains the original DireContainer API you know and love
///
/// ## Quick Start
///
/// Add to your `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   dire_di: ^1.0.3
///
/// dev_dependencies:
///   build_runner: ^2.4.7
/// ```
///
/// Annotate your classes (same as before):
/// ```dart
/// import 'package:dire_di/dire_di.dart';
///
/// @Service()
/// class UserService {
///   final UserRepository userRepository;
///
///   UserService(this.userRepository); // Constructor injection
///
///   Future<User> getUser(int id) {
///     return userRepository.findById(id);
///   }
/// }
///
/// @Repository()
/// class UserRepository {
///   Future<User> findById(int id) async {
///     // Implementation here
///   }
/// }
/// ```
///
/// Run code generation:
/// ```bash
/// flutter pub get
/// flutter pub run build_runner build
/// ```
///
/// Use in your app (same API as before):
/// ```dart
/// void main() async {
///   final container = DireContainer();
///   await container.scan(); // Now uses generated code instead of mirrors
///
///   final userService = container.get<UserService>();
///   // userService.userRepository is automatically injected!
/// }
/// ```
///
/// ## Migration from Mirrors
///
/// If you're migrating from the old mirrors-based version:
///
/// 1. **Change from field injection to constructor injection**:
///    ```dart
///    // Before (mirrors)
///    @Service()
///    class UserService {
///      @Autowired()
///      late UserRepository userRepository;
///    }
///
///    // After (code generation)
///    @Service()
///    class UserService {
///      final UserRepository userRepository;
///      UserService(this.userRepository);
///    }
///    ```
///
/// 2. **Add build_runner and run code generation**:
///    ```bash
///    flutter pub add --dev build_runner
///    flutter pub run build_runner build
///    ```
///
/// 3. **Same API** - No changes to your main() or container usage!
///
/// ## Advanced Usage
///
/// ### Named Instances (Qualifiers)
///
/// ```dart
/// @Service()
/// @Qualifier('primary')
/// class PrimaryUserService extends UserService {
///   // Implementation
/// }
///
/// // Usage - same as before
/// final primary = container.get<UserService>('primary');
/// ```
///
/// ### Singletons vs Prototype
///
/// ```dart
/// @Service()
/// @Singleton() // Single instance
/// class DatabaseConnection {
///   // Implementation
/// }
///
/// @Service()
/// @Prototype() // New instance each time
/// class RequestHandler {
///   // Implementation
/// }
/// ```
///
/// ### Environment-specific Beans
///
/// ```dart
/// @Service()
/// @Profile('dev')
/// class DevUserService extends UserService {
///   // Development implementation
/// }
///
/// @Service()
/// @Profile('prod')
/// class ProdUserService extends UserService {
///   // Production implementation
/// }
/// ```
///
/// ## Benefits of Code Generation
///
/// - ✅ **Flutter Compatible** - No dart:mirrors dependency
/// - ✅ **Better Performance** - No runtime reflection overhead
/// - ✅ **Compile-time Safety** - Dependency errors caught at build time
/// - ✅ **Tree Shaking** - Only used dependencies in final bundle
/// - ✅ **Same API** - Your existing code mostly unchanged
/// - ✅ **IDE Support** - Better autocomplete and refactoring
///
/// ```dart
/// @Service()
/// @Qualifier('primary')
/// class PrimaryUserService implements UserService { }
///
/// @Service()
/// @Qualifier('secondary')
/// class SecondaryUserService implements UserService { }
///
/// @Component()
/// class UserController {
///   @Autowired()
///   @Qualifier('primary')
///   late UserService userService;
/// }
/// ```
///
/// ### Configuration Classes
///
/// ```dart
/// @Configuration()
/// class DatabaseConfig {
///   @Bean()
///   @Singleton()
///   Database createDatabase() {
///     return Database(connectionString: 'localhost:5432');
///   }
/// }
/// ```
///
/// ### Profiles
///
/// ```dart
/// @Service()
/// @Profile('development')
/// class DevUserService implements UserService { }
///
/// @Service()
/// @Profile('production')
/// class ProdUserService implements UserService { }
/// ```
library dire_di;

// Annotations
export 'src/annotations/autowired.dart';
export 'src/annotations/bean.dart';
export 'src/annotations/component.dart';
export 'src/annotations/conditional.dart';
export 'src/annotations/configuration.dart';
export 'src/annotations/controller.dart';
export 'src/annotations/dire_di_entry_point.dart';
export 'src/annotations/profile.dart';
export 'src/annotations/qualifier.dart';
export 'src/annotations/repository.dart';
export 'src/annotations/scope.dart';
export 'src/annotations/service.dart';
// Core container (code generation based)
export 'src/container/dire_container.dart';
// Core types
export 'src/core/bean_definition.dart';
export 'src/core/injection_context.dart';
export 'src/core/scope_type.dart';
// Exceptions
export 'src/exceptions/dire_exceptions.dart';
// Injection setup
export 'src/injection.dart';
// Utilities
export 'src/utils/type_utils.dart';
