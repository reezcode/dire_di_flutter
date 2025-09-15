// Flutter Widget Integration Example for DireDi
// This file demonstrates proper patterns for using DiCore and DiMixin in Flutter widgets

import 'package:dire_di_flutter/dire_di.dart';

// Import the generated registration file
import 'app_module.dire_di.dart';
import 'controllers/user_controller.dart';
import 'services/database_service.dart';
import 'services/user_service.dart';

/// Example demonstrating proper Flutter integration with DiCore and DiMixin
///
/// IMPORTANT PATTERNS FOR FLUTTER USAGE:
///
/// 1. PRE-INITIALIZE IN MAIN():
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // CRITICAL: Pre-initialize DI container with dependency registration
///   await DiCore.initialize((container) => container.registerGeneratedDependencies());
///
///   runApp(MyApp());
/// }
/// ```
///
/// 2. USE ASYNC PATTERN IN WIDGETS:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with DiCore, DiMixin {
///   UserService? userService;
///   bool isLoading = true;
///
///   @override
///   void initState() {
///     super.initState();
///     _loadDependencies();
///   }
///
///   void _loadDependencies() async {
///     try {
///       // Option A: Use convenience properties (recommended)
///       userService = await userServiceAsync;
///
///       // Option B: Use direct async access
///       // userService = await getAsync<UserService>();
///
///       setState(() {
///         isLoading = false;
///       });
///     } catch (e) {
///       print('DI Error: $e');
///       setState(() {
///         isLoading = false;
///       });
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     if (isLoading) {
///       return CircularProgressIndicator();
///     }
///
///     return Text('User: ${userService?.getCurrentUser() ?? "None"}');
///   }
/// }
/// ```
///
/// 3. AVOID SYNCHRONOUS ACCESS IN INITSTATE:
/// ```dart
/// // ❌ DON'T DO THIS - Will cause exceptions
/// @override
/// void initState() {
///   super.initState();
///   userService = get<UserService>(); // This will throw!
/// }
///
/// // ✅ DO THIS INSTEAD - Use async pattern
/// @override
/// void initState() {
///   super.initState();
///   _initAsync();
/// }
///
/// void _initAsync() async {
///   userService = await getAsync<UserService>();
///   setState(() {});
/// }
/// ```

Future<void> main() async {
  print('=== Flutter Convenience Example ===');
  print('This demonstrates proper DI patterns for Flutter widgets.');
  print('');

  // Simulate Flutter app initialization
  await simulateFlutterAppInit();

  // Demonstrate widget patterns
  await demonstrateWidgetPatterns();

  // Print best practices summary
  printBestPractices();
}

/// Simulates proper Flutter app initialization with DI
Future<void> simulateFlutterAppInit() async {
  print('1. Initializing DI container (like in main())...');

  // This is what you should do in your Flutter main() method
  await DiCore.initialize(
      (container) => container.registerGeneratedDependencies(),);

  print('   ✅ DI container pre-initialized successfully');
  print('   ✅ Generated dependencies registered via callback');
}

/// Demonstrates proper widget usage patterns
Future<void> demonstrateWidgetPatterns() async {
  print('');
  print('2. Demonstrating widget patterns...');

  // Simulate a widget state class
  final widgetState = ExampleWidgetState();
  await widgetState.simulateInitState();

  await widgetState.simulateBuildAndInteraction();
}

/// Example widget state demonstrating proper DI usage
class ExampleWidgetState with DiCore, DiMixin {
  UserService? _userService;
  UserController? _userController;
  DatabaseService? _databaseService;
  bool isLoading = true;
  String displayText = 'Loading...';

  /// Simulates Flutter's initState() method
  Future<void> simulateInitState() async {
    print('   📱 Widget initState() called');
    await _loadDependencies();
  }

  /// Proper async dependency loading pattern
  Future<void> _loadDependencies() async {
    try {
      print('   🔄 Loading dependencies asynchronously...');

      // Method 1: Use convenience properties (recommended)
      _userService = await userServiceAsync;
      _userController = await userControllerAsync;
      _databaseService = await databaseServiceAsync;

      // Method 2: Direct async access (alternative)
      // _userService = await getAsync<UserService>();
      // _userController = await getAsync<UserController>();

      isLoading = false;
      displayText = 'Dependencies loaded successfully!';

      print('   ✅ All dependencies loaded');

      // In real Flutter, you would call setState() here
      // setState(() {});
    } catch (e) {
      print('   ❌ Error loading dependencies: $e');
      isLoading = false;
      displayText = 'Error: $e';

      // In real Flutter, you would call setState() here
      // setState(() {});
    }
  }

  /// Simulates Flutter's build() method and user interaction
  Future<void> simulateBuildAndInteraction() async {
    print('   🎨 Widget build() called');

    if (isLoading) {
      print('      Displaying: Loading indicator');
      return;
    }

    print('      Displaying: $displayText');

    // Simulate user interaction
    print('   👆 User interaction - refreshing data...');
    await _refreshData();
  }

  /// Demonstrates safe dependency usage after loading
  Future<void> _refreshData() async {
    try {
      if (_userController != null) {
        _userController!.handleGetUser('123');
        print('   ✅ User data refreshed successfully');
      }

      // You can also get additional dependencies on demand
      final repository = await userRepositoryAsync;
      print('   ✅ Repository accessed: ${repository.runtimeType}');
    } catch (e) {
      print('   ❌ Error refreshing data: $e');
    }
  }
}

/// Summary of best practices demonstrated:
void printBestPractices() {
  print('');
  print('=== BEST PRACTICES SUMMARY ===');
  print('');
  print('✅ DO:');
  print(
      '   • Pre-initialize DI in main() with callback: await DiCore.initialize((c) => c.registerGeneratedDependencies())',);
  print('   • Use async patterns in widget initState()');
  print(
      '   • Use convenience properties from DiMixin (e.g., userServiceAsync)',);
  print('   • Handle loading states properly');
  print('   • Use setState() after async operations');
  print('');
  print('❌ DON\'T:');
  print('   • Use synchronous get<T>() in initState()');
  print('   • Assume dependencies are immediately available');
  print('   • Ignore error handling in async operations');
  print('   • Forget to call setState() after loading');
}
