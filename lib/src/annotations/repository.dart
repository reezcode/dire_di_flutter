import 'component.dart';

/// Repository layer annotation - indicates data access layer components
///
/// This annotation is a specialization of [@Component] for classes that
/// provide data access functionality, typically interacting with databases
/// or external data sources.
///
/// Example:
/// ```dart
/// @Repository()
/// class UserRepository {
///   Future<User?> findById(int id) async {
///     // Database access logic here
///   }
///
///   Future<void> save(User user) async {
///     // Save logic here
///   }
/// }
/// ```
class Repository extends Component {
  const Repository([super.value]);
}
