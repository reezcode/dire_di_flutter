/// Enumeration of bean scope types
///
/// Defines the lifecycle and sharing behavior of beans in the DI container.
enum ScopeType {
  /// Singleton scope - only one instance is created and shared
  ///
  /// The same instance is returned for every injection request.
  /// This is the default scope for most use cases.
  singleton,

  /// Prototype scope - a new instance is created for each injection
  ///
  /// A new instance is created every time the bean is requested.
  /// Useful for stateful beans or when you need fresh instances.
  prototype,

  /// Request scope - one instance per request (web applications)
  ///
  /// A new instance is created for each HTTP request and shared
  /// within that request context. Requires web context support.
  request,

  /// Session scope - one instance per session (web applications)
  ///
  /// A new instance is created for each user session and shared
  /// within that session context. Requires web context support.
  session,

  /// Application scope - similar to singleton but explicitly scoped to application
  ///
  /// Similar to singleton but with explicit application-level lifecycle.
  application,
}
