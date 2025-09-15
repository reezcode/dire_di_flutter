import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import '../core/scope_type.dart';
import 'di_generator.dart';

/// Extended ComponentInfo that includes source file information
class ComponentInfoWithSource extends ComponentInfo {

  ComponentInfoWithSource({
    required super.className,
    required super.componentType,
    super.beanName,
    required super.scope,
    required super.profiles,
    super.constructorDependencies = const [],
    super.autowiredFields = const [],
    required this.sourceFile,
  });
  final String sourceFile;
}

/// Aggregating builder that collects all DI components from the entire project
/// and generates a single consolidated registration file at the entry point.
class DireDiAggregatingBuilder implements Builder {
  const DireDiAggregatingBuilder();

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.dire_di.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process files that have @DireDiEntryPoint annotation
    final library = LibraryReader(await buildStep.inputLibrary);

    // Check if this file has @DireDiEntryPoint annotation
    final hasEntryPoint = await _hasEntryPointAnnotation(library);
    if (!hasEntryPoint) {
      // Skip files without entry point annotation
      return;
    }

    log.info('Found @DireDiEntryPoint in ${buildStep.inputId.path}');

    // Collect all components from all Dart files in the project
    final allComponents = await _collectAllComponents(buildStep);

    if (allComponents.isEmpty) {
      log.warning('No DI components found in the project');
      return;
    }

    log.info('Found ${allComponents.length} DI components to register');

    // Generate consolidated registration code
    final code = _generateConsolidatedCode(allComponents, buildStep.inputId);

    // Write the consolidated file
    final outputId = buildStep.inputId.changeExtension('.dire_di.dart');
    await buildStep.writeAsString(outputId, code);

    log.info('Generated consolidated DI file: ${outputId.path}');
  }

  Future<bool> _hasEntryPointAnnotation(LibraryReader library) async {
    for (final element in library.allElements) {
      if (element is ClassElement) {
        final hasEntryPoint = element.metadata
            .any((meta) => meta.element?.displayName == 'DireDiEntryPoint');
        if (hasEntryPoint) {
          return true;
        }
      }
    }
    return false;
  }

  Future<List<ComponentInfoWithSource>> _collectAllComponents(
      BuildStep buildStep,) async {
    final allComponents = <ComponentInfoWithSource>[];

    // Find all Dart files in the project - both lib and example directories
    final dartFilesLib = Glob('lib/**.dart');
    final dartFilesExample = Glob('example/**.dart');

    // Process lib files
    await for (final assetId in buildStep.findAssets(dartFilesLib)) {
      await _processFile(assetId, buildStep, allComponents);
    }

    // Process example files
    await for (final assetId in buildStep.findAssets(dartFilesExample)) {
      await _processFile(assetId, buildStep, allComponents);
    }

    log.info('Total components found: ${allComponents.length}');
    return allComponents;
  }

  Future<void> _processFile(AssetId assetId, BuildStep buildStep,
      List<ComponentInfoWithSource> allComponents,) async {
    try {
      // Skip generated files
      if (assetId.path.contains('.g.dart') ||
          assetId.path.contains('.dire_di.dart') ||
          assetId.path.contains('.freezed.dart')) {
        return;
      }

      log.fine('Processing file: ${assetId.path}');

      final library =
          LibraryReader(await buildStep.resolver.libraryFor(assetId));

      // Use the existing DiGenerator logic to extract components
      final generator = DiGenerator();
      final components = generator.extractComponentsFromLibrary(library);

      // Add source file information to each component
      final componentsWithSource = components
          .map((c) => ComponentInfoWithSource(
                className: c.className,
                componentType: c.componentType,
                beanName: c.beanName,
                scope: c.scope,
                profiles: c.profiles,
                constructorDependencies: c.constructorDependencies,
                autowiredFields: c.autowiredFields,
                sourceFile: assetId.path,
              ),)
          .toList();

      allComponents.addAll(componentsWithSource);

      if (components.isNotEmpty) {
        log.info('Found ${components.length} components in ${assetId.path}');
        for (final component in components) {
          log.info('  - ${component.className} (${component.componentType})');
        }
      }
    } catch (e) {
      log.warning('Failed to process ${assetId.path}: $e');
    }
  }

  String _generateConsolidatedCode(
      List<ComponentInfoWithSource> components, AssetId inputId,) {
    final buffer = StringBuffer();

    // Generate header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln(
        '// **************************************************************************',);
    buffer.writeln('// DireDi Aggregating Generator');
    buffer.writeln(
        '// **************************************************************************',);
    buffer.writeln();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by dire_di aggregating code generator');
    buffer.writeln('// Entry point: ${inputId.path}');
    buffer.writeln('// Components found: ${components.length}');
    buffer.writeln();

    // Add imports
    buffer.writeln("import 'package:dire_di_flutter/dire_di.dart';");
    buffer.writeln();

    // Add imports for all files that contain components
    final importPaths = components
        .map((c) => c.sourceFile)
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    for (final importPath in importPaths) {
      // Convert absolute path to relative import
      final relativePath = _makeRelativeImport(inputId.path, importPath);
      buffer.writeln("import '$relativePath';");
    }
    buffer.writeln();

    // Generate extension with all registrations
    buffer.writeln('extension GeneratedDependencies on DireContainer {');
    buffer.writeln(
        '  /// Register all discovered components from the entire project',);
    buffer.writeln('  void registerGeneratedDependencies() {');

    // Sort components by dependency order (dependencies first)
    final sortedComponents = _sortComponentsByDependencies(components);

    for (final component in sortedComponents) {
      buffer.writeln('    // Register ${component.className}');
      buffer.writeln(_generateComponentRegistration(component));
      buffer.writeln();
    }

    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _makeRelativeImport(String fromPath, String toPath) {
    // Convert absolute path to relative import
    // Both fromPath and toPath should start with 'example/' or 'lib/'

    // Remove common prefix if both are in same directory structure
    if (fromPath.startsWith('example/') && toPath.startsWith('example/')) {
      // Both in example directory
      final toParts = toPath.split('/');

      // Remove common 'example/' prefix
      final relativeToPath = toParts.skip(1).join('/');
      return relativeToPath;
    } else if (fromPath.startsWith('lib/') && toPath.startsWith('lib/')) {
      // Both in lib directory
      final toParts = toPath.split('/');

      // Remove common 'lib/' prefix
      final relativeToPath = toParts.skip(1).join('/');
      return relativeToPath;
    } else {
      // Cross-directory reference, use relative path
      if (toPath.startsWith('lib/')) {
        return '../${toPath.substring(4)}'; // Remove 'lib/' and add '../'
      }
      return toPath;
    }
  }

  List<ComponentInfoWithSource> _sortComponentsByDependencies(
      List<ComponentInfoWithSource> components,) {
    // Simple topological sort based on constructor dependencies
    final sorted = <ComponentInfoWithSource>[];
    final visited = <String>{};
    final visiting = <String>{};

    void visit(ComponentInfoWithSource component) {
      if (visiting.contains(component.className)) {
        // Circular dependency detected, but we'll handle it
        return;
      }
      if (visited.contains(component.className)) {
        return;
      }

      visiting.add(component.className);

      // Visit dependencies first
      for (final dep in component.constructorDependencies) {
        final depComponent = components.firstWhere(
          (c) => c.className == dep.type,
          orElse: () => ComponentInfoWithSource(
            className: '',
            componentType: '',
            scope: ScopeType.singleton,
            profiles: [],
            sourceFile: '',
          ),
        );
        if (depComponent.className.isNotEmpty) {
          visit(depComponent);
        }
      }

      visiting.remove(component.className);
      visited.add(component.className);
      sorted.add(component);
    }

    for (final component in components) {
      visit(component);
    }

    return sorted;
  }

  String _generateComponentRegistration(ComponentInfoWithSource component) {
    final buffer = StringBuffer();

    // Start registration
    buffer.write('    register<${component.className}>(');
    buffer.writeln();
    buffer.write('      () ');

    // Generate constructor call and field injection
    if (component.constructorDependencies.isEmpty &&
        component.autowiredFields.isEmpty) {
      // Simple case: no dependencies
      buffer.write('=> ${component.className}(),');
    } else {
      // Complex case: has dependencies
      buffer.writeln('{');

      if (component.constructorDependencies.isNotEmpty) {
        // Constructor injection
        buffer.write('        final instance = ${component.className}(');
        final constructorArgs = component.constructorDependencies
            .map((dep) => 'get<${dep.type}>()')
            .join(', ');
        buffer.write(constructorArgs);
        buffer.writeln(');');
      } else {
        // No constructor dependencies
        buffer.writeln('        final instance = ${component.className}();');
      }

      // Field injection
      for (final field in component.autowiredFields) {
        buffer.writeln(
            '        instance.${field.fieldName} = get<${field.type}>();',);
      }

      buffer.writeln('        return instance;');
      buffer.write('      },');
    }

    buffer.writeln();
    buffer.write('      scope: ScopeType.${component.scope.name},');
    buffer.writeln();
    buffer.write('    );');

    return buffer.toString();
  }
}
