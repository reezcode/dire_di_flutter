/// Controller annotation for marking web controllers and similar components.
/// Controllers typically handle HTTP requests, user input, or other external interfaces.
class Controller {
  /// Creates a new Controller annotation
  const Controller([this.name]);

  /// Optional name for this controller instance
  final String? name;
}
