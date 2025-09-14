/// Core component annotation - base for all stereotypes
///
/// This is the base annotation for all component stereotypes like
/// [@Service], [@Repository], [@Controller], etc.
///
/// Example:
/// ```dart
/// @Component()
/// class MyComponent {
///   // Your component logic here
/// }
/// ```
class Component {
  const Component([this.value]);

  /// Optional value to specify the component name
  final String? value;
}
