/// Marks a file as the entry point for DI code generation.
///
/// When this annotation is used, all DI components found across
/// the entire project will be consolidated into a single generated
/// registration file alongside this annotated class.
///
/// This ensures that `registerGeneratedDependencies()` only needs
/// to be called once from a single location.
///
/// Example:
/// ```dart
/// @DireDiEntryPoint()
/// class AppModule {
///   // This file will receive the consolidated registration code
/// }
/// ```
class DireDiEntryPoint {
  /// Creates a DI entry point annotation.
  ///
  /// [outputFileName] optionally specifies the name of the generated file.
  /// If not provided, it defaults to the current file name with `.dire_di.dart` extension.
  const DireDiEntryPoint({this.outputFileName});

  /// The name of the generated file (optional).
  /// If not provided, uses the default pattern: `{filename}.dire_di.dart`
  final String? outputFileName;
}
