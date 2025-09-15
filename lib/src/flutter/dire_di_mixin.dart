import '../container/dire_container.dart';
import '../core/scope_type.dart';

/// Mixin for StatefulWidget States that provides easy access to dependency injection.
///
/// This mixin automatically initializes the DireContainer with discovered dependencies
/// and provides convenient methods to resolve dependencies without manual container management.
///
/// **Important**: To register generated dependencies, you must import your generated
/// `.dire_di.dart` file and call `registerGeneratedDependencies()` manually in your app initialization:
///
/// ```dart
/// // main.dart
/// import 'package:flutter/material.dart';
/// import 'package:dire_di/dire_di.dart';
/// import 'app_module.dire_di.dart'; // Your generated file
///
/// void main() async {
///   await DiCore.initialize();
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatefulWidget {
///   @override
///   _MyAppState createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> with DiCore {
///   @override
///   void initState() {
///     super.initState();
///     // Register generated dependencies
///     container.then((cont) => cont.registerGeneratedDependencies());
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: MyHomePage(),
///     );
///   }
/// }
/// ```
///
/// Or use it in individual widgets:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> with DiCore {
///   late UserService userService;
///
///   @override
///   void initState() {
///     super.initState();
///     userService = get<UserService>();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Text('User: ${userService.getCurrentUser()}');
///   }
/// }
/// ```
mixin DiCore {
  static DireContainer? _globalContainer;
  static bool _isInitialized = false;

  /// Gets the global DireContainer instance, initializing it if necessary.
  /// This is called automatically when using the get<T>() method.
  Future<DireContainer> get container async {
    if (!_isInitialized) {
      await _initializeContainer();
    }
    return _globalContainer!;
  }

  /// Initialize the global container with generated dependencies.
  /// This method is called automatically on first access.
  static Future<void> _initializeContainer() async {
    if (_isInitialized) return;

    _globalContainer = DireContainer();
    await _globalContainer!.scan();

    // Note: registerGeneratedDependencies() is an extension method from generated code.
    // Users need to ensure they import their generated .dire_di.dart file where this
    // mixin is used for the extension to be available.

    _isInitialized = true;
  }

  /// Manually initialize the DI container.
  /// Call this in your app's main() method if you want to pre-initialize the container.
  ///
  /// Example:
  /// ```dart
  /// void main() async {
  ///   await DiCore.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize() async {
    await _initializeContainer();
  }

  /// Reset the container (useful for testing).
  static void reset() {
    _globalContainer = null;
    _isInitialized = false;
  }

  /// Get a dependency of type T from the container.
  /// The container is automatically initialized on first use.
  ///
  /// Example:
  /// ```dart
  /// final userService = get<UserService>();
  /// final namedService = get<UserService>('special');
  /// ```
  T get<T extends Object>([String? qualifier]) {
    if (!_isInitialized) {
      throw StateError(
        'DireContainer not initialized. Call await get<T>() or use getAsync<T>() for automatic initialization.',
      );
    }
    return _globalContainer!.get<T>(qualifier);
  }

  /// Asynchronously get a dependency of type T from the container.
  /// This method automatically initializes the container if needed.
  ///
  /// Example:
  /// ```dart
  /// final userService = await getAsync<UserService>();
  /// final namedService = await getAsync<UserService>('special');
  /// ```
  Future<T> getAsync<T extends Object>([String? qualifier]) async {
    final cont = await container;
    return cont.get<T>(qualifier);
  }

  /// Check if a dependency of type T is registered in the container.
  ///
  /// Example:
  /// ```dart
  /// if (has<UserService>()) {
  ///   final service = get<UserService>();
  /// }
  /// ```
  bool has<T extends Object>([String? qualifier]) {
    if (!_isInitialized) return false;
    return _globalContainer!.contains<T>(qualifier);
  }

  /// Asynchronously check if a dependency of type T is registered in the container.
  /// This method automatically initializes the container if needed.
  Future<bool> hasAsync<T extends Object>([String? qualifier]) async {
    final cont = await container;
    return cont.contains<T>(qualifier);
  }

  /// Register a dependency manually.
  /// This is useful for registering dependencies that aren't annotated.
  ///
  /// Example:
  /// ```dart
  /// register<ApiClient>(() => ApiClient(baseUrl: 'https://api.example.com'));
  /// ```
  Future<void> register<T extends Object>(
    T Function() factory, {
    String? name,
    ScopeType scope = ScopeType.singleton,
  }) async {
    final cont = await container;
    cont.register<T>(factory, name: name, scope: scope);
  }

  /// Get all dependencies of type T from the container.
  ///
  /// Example:
  /// ```dart
  /// final allServices = getAll<UserService>();
  /// ```
  List<T> getAll<T extends Object>() {
    if (!_isInitialized) {
      throw StateError(
        'DireContainer not initialized. Call await getAll<T>() or use getAllAsync<T>() for automatic initialization.',
      );
    }
    return _globalContainer!.getAll<T>();
  }

  /// Asynchronously get all dependencies of type T from the container.
  /// This method automatically initializes the container if needed.
  Future<List<T>> getAllAsync<T extends Object>() async {
    final cont = await container;
    return cont.getAll<T>();
  }
}
