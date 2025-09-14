import 'component.dart';

/// Service layer annotation - indicates that this class provides business logic
///
/// This annotation is a specialization of [@Component] for classes that
/// contain business logic or service operations.
///
/// Example:
/// ```dart
/// @Service()
/// class UserService {
///   final UserRepository userRepository;
///
///   UserService(this.userRepository);
///
///   Future<User> getUser(int id) {
///     return userRepository.findById(id);
///   }
/// }
/// ```
class Service extends Component {
  const Service([super.value]);
}
