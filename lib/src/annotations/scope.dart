import '../core/scope_type.dart';

/// Scope annotation for controlling bean lifecycle
///
/// Specifies the scope of a bean, determining when and how many instances
/// are created.
///
/// Example:
/// ```dart
/// @Service()
/// @Scope(ScopeType.singleton)
/// class ConfigurationService {
///   // Single instance shared across the application
/// }
///
/// @Service()
/// @Scope(ScopeType.prototype)
/// class RequestProcessor {
///   // New instance created for each injection
/// }
/// ```
class Scope {
  const Scope(this.value);

  /// The scope type for the bean
  final ScopeType value;
}

/// Convenience annotation for singleton scope
///
/// Equivalent to @Scope(ScopeType.singleton)
class Singleton extends Scope {
  const Singleton() : super(ScopeType.singleton);
}

/// Convenience annotation for prototype scope
///
/// Equivalent to @Scope(ScopeType.prototype)
class Prototype extends Scope {
  const Prototype() : super(ScopeType.prototype);
}
