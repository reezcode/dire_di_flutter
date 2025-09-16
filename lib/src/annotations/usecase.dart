import 'component.dart';

/// UseCase layer annotation - indicates application use case components
///
/// This annotation is a specialization of [@Component] for classes that
/// contain specific business use cases or application logic, following
/// Clean Architecture principles.
///
/// Use cases encapsulate application-specific business rules and orchestrate
/// the flow of data to and from entities and repositories.
///
/// Example:
/// ```dart
/// @UseCase()
/// class GetUserUseCase {
///   @Autowired()
///   late UserRepository userRepository;
///
///   Future<User?> execute(String userId) async {
///     return await userRepository.findById(userId);
///   }
/// }
/// ```
class UseCase extends Component {
  /// Creates a UseCase annotation
  ///
  /// [value] - Optional name for the use case component
  const UseCase([super.value]);
}
