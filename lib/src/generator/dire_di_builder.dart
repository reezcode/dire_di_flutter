import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../core/scope_type.dart';

/// ComponentInfo without source_gen dependency
class ComponentInfo {
  ComponentInfo({
    required this.className,
    required this.componentType,
    this.beanName,
    required this.scope,
    required this.profiles,
    this.constructorDependencies = const [],
    this.autowiredFields = const [],
  });
  final String className;
  final String componentType;
  final String? beanName;
  final ScopeType scope;
  final List<String> profiles;
  final List<DependencyInfo> constructorDependencies;
  final List<FieldDependencyInfo> autowiredFields;
}

class DependencyInfo {
  DependencyInfo({
    required this.type,
    required this.name,
    required this.isRequired,
    this.qualifier,
  });
  final String type;
  final String name;
  final bool isRequired;
  final String? qualifier;
}

class FieldDependencyInfo {
  FieldDependencyInfo({
    required this.fieldName,
    required this.type,
    this.qualifier,
    required this.isNullable,
  });
  final String fieldName;
  final String type;
  final String? qualifier;
  final bool isNullable;
}

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

/// Mirrors-free aggregating builder using only analyzer package
class DireDiAggregatingBuilder implements Builder {
  const DireDiAggregatingBuilder();

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.dire_di.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process files that have @DireDiEntryPoint annotation
    final library = await buildStep.inputLibrary;

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

  Future<bool> _hasEntryPointAnnotation(LibraryElement library) async {
    for (final element in library.topLevelElements) {
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
    BuildStep buildStep,
  ) async {
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

  Future<void> _processFile(
    AssetId assetId,
    BuildStep buildStep,
    List<ComponentInfoWithSource> allComponents,
  ) async {
    try {
      // Skip generated files
      if (assetId.path.contains('.g.dart') ||
          assetId.path.contains('.dire_di.dart') ||
          assetId.path.contains('.freezed.dart')) {
        return;
      }

      log.fine('Processing file: ${assetId.path}');

      final library = await buildStep.resolver.libraryFor(assetId);

      // Extract components using only analyzer package
      final components = _extractComponentsFromLibrary(library);

      // Add source file information to each component
      final componentsWithSource = components
          .map(
            (c) => ComponentInfoWithSource(
              className: c.className,
              componentType: c.componentType,
              beanName: c.beanName,
              scope: c.scope,
              profiles: c.profiles,
              constructorDependencies: c.constructorDependencies,
              autowiredFields: c.autowiredFields,
              sourceFile: assetId.path,
            ),
          )
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

  List<ComponentInfo> _extractComponentsFromLibrary(LibraryElement library) {
    final components = <ComponentInfo>[];

    // Scan all classes in the library
    for (final element in library.topLevelElements) {
      if (element is ClassElement && !element.isAbstract) {
        if (_hasComponentAnnotation(element)) {
          final info = _extractComponentInfo(element);
          components.add(info);
        }
      }
    }

    return components;
  }

  bool _hasComponentAnnotation(ClassElement element) =>
      element.metadata.any((meta) {
        final annotationName = meta.element?.displayName;
        return annotationName == 'Service' ||
            annotationName == 'Repository' ||
            annotationName == 'Controller' ||
            annotationName == 'Component';
      });

  ComponentInfo _extractComponentInfo(ClassElement element) {
    String componentType = 'Component';
    String? beanName;
    ScopeType scope = ScopeType.singleton;
    final List<String> profiles = [];

    // Extract annotation information
    for (final meta in element.metadata) {
      final annotationType = meta.element?.displayName;

      switch (annotationType) {
        case 'Service':
          componentType = 'Service';
          break;
        case 'Repository':
          componentType = 'Repository';
          break;
        case 'Controller':
          componentType = 'Controller';
          break;
        case 'Component':
          componentType = 'Component';
          break;
        case 'Scope':
          scope = _extractScope(meta);
          break;
        case 'Qualifier':
          beanName = _extractQualifierValue(meta);
          break;
      }
    }

    // Extract constructor dependencies
    final constructorDeps = _extractConstructorDependencies(element);

    // Extract autowired field dependencies
    final fieldDeps = _extractAutowiredFields(element);

    return ComponentInfo(
      className: element.displayName,
      componentType: componentType,
      beanName: beanName,
      scope: scope,
      profiles: profiles,
      constructorDependencies: constructorDeps,
      autowiredFields: fieldDeps,
    );
  }

  List<DependencyInfo> _extractConstructorDependencies(ClassElement element) {
    final dependencies = <DependencyInfo>[];

    // Find the constructor
    final constructor = element.constructors
            .where(
              (c) => c.displayName.isEmpty, // Default constructor
            )
            .firstOrNull ??
        (element.constructors.isNotEmpty ? element.constructors.first : null);

    if (constructor != null) {
      // Extract constructor parameters as dependencies
      for (final param in constructor.parameters) {
        dependencies.add(
          DependencyInfo(
            type: param.type.getDisplayString(withNullability: false),
            name: param.displayName,
            isRequired: param.isRequired,
            qualifier: _extractQualifier(param),
          ),
        );
      }
    }

    return dependencies;
  }

  List<FieldDependencyInfo> _extractAutowiredFields(ClassElement element) {
    final fields = <FieldDependencyInfo>[];

    for (final field in element.fields) {
      // Check if field has @Autowired annotation
      final hasAutowired = field.metadata.any(
        (meta) => meta.element?.enclosingElement?.displayName == 'Autowired',
      );

      if (hasAutowired) {
        final qualifier = _extractFieldQualifier(field);
        fields.add(
          FieldDependencyInfo(
            fieldName: field.displayName,
            type: field.type.getDisplayString(withNullability: false),
            qualifier: qualifier,
            isNullable: field.type
                .getDisplayString(withNullability: true)
                .endsWith('?'),
          ),
        );
      }
    }

    return fields;
  }

  String? _extractFieldQualifier(FieldElement field) {
    for (final meta in field.metadata) {
      if (meta.element?.enclosingElement?.displayName == 'Qualifier') {
        // Extract qualifier value
        return 'primary'; // Simplified implementation
      }
    }
    return null;
  }

  String? _extractQualifierValue(ElementAnnotation meta) {
    // Extract qualifier value from annotation
    return null; // Simplified implementation
  }

  ScopeType _extractScope(ElementAnnotation meta) {
    // Extract scope from annotation value
    return ScopeType.singleton; // Default implementation
  }

  String? _extractQualifier(ParameterElement param) {
    // Check for @Qualifier annotation
    for (final meta in param.metadata) {
      if (meta.element?.enclosingElement?.displayName == 'Qualifier') {
        // Extract qualifier value
        return null; // Simplified implementation
      }
    }
    return null;
  }

  String _generateConsolidatedCode(
    List<ComponentInfoWithSource> components,
    AssetId inputId,
  ) {
    final buffer = StringBuffer();

    // Generate header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln(
      '// **************************************************************************',
    );
    buffer.writeln('// DireDi Generator');
    buffer.writeln(
      '// **************************************************************************',
    );
    buffer.writeln();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by dire_di code generator');
    buffer.writeln('// Entry point: ${inputId.path}');
    buffer.writeln('// Components found: ${components.length}');
    buffer.writeln();

    // Add imports
    buffer.writeln("import 'package:dire_di_flutter/dire_di.dart';");
    // Add imports for the DI framework
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
      '  /// Register all discovered components from the entire project',
    );
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
    buffer.writeln();

    // Generate convenience mixin extension with auto-generated getters
    _generateDireDiConvenienceMixin(buffer, components);

    return buffer.toString();
  }

  /// Generate convenience mixin extension with auto-generated getters for each component
  void _generateDireDiConvenienceMixin(
    StringBuffer buffer,
    List<ComponentInfoWithSource> components,
  ) {
    buffer.writeln(
      '/// Convenience mixin that provides direct property access to DI components.',
    );
    buffer.writeln(
      '/// Add this mixin to your StatefulWidget states for easy dependency access.',
    );
    buffer.writeln('///');
    buffer.writeln('/// Example:');
    buffer.writeln('/// ```dart');
    buffer.writeln(
      '/// class _MyWidgetState extends State<MyWidget> with DiCore, DiMixin {',
    );
    buffer.writeln('///   @override');
    buffer.writeln('///   Widget build(BuildContext context) {');
    buffer.writeln(
      '///     return Text(userService.getCurrentUser()); // Direct access!',
    );
    buffer.writeln('///   }');
    buffer.writeln('/// }');
    buffer.writeln('/// ```');
    buffer.writeln('mixin DiMixin {');
    buffer.writeln();

    // Generate getter for each component
    for (final component in components) {
      final className = component.className;
      final propertyName = _getPropertyName(className);

      buffer.writeln('  /// Get $className instance from DI container');
      buffer.writeln('  $className get $propertyName {');
      buffer.writeln('    if (this is DiCore) {');
      buffer.writeln('      return (this as DiCore).get<$className>();');
      buffer.writeln('    }');
      buffer.writeln('    throw StateError(');
      buffer.writeln('      \'DiMixin must be used with DiCore. \'');
      buffer.writeln('      \'Add "with DiCore, DiMixin" to your class.\',');
      buffer.writeln('    );');
      buffer.writeln('  }');
      buffer.writeln();

      // Also generate async getter
      buffer.writeln('  /// Get $className instance from DI container (async)');
      buffer.writeln('  Future<$className> get ${propertyName}Async async {');
      buffer.writeln('    if (this is DiCore) {');
      buffer.writeln('      return (this as DiCore).getAsync<$className>();');
      buffer.writeln('    }');
      buffer.writeln('    throw StateError(');
      buffer.writeln('      \'DiMixin must be used with DiCore. \'');
      buffer.writeln('      \'Add "with DiCore, DiMixin" to your class.\',');
      buffer.writeln('    );');
      buffer.writeln('  }');
      buffer.writeln();
    }

    buffer.writeln('}');
  }

  /// Convert class name to property name (e.g., UserService -> userService)
  String _getPropertyName(String className) {
    if (className.isEmpty) return className;
    return className[0].toLowerCase() + className.substring(1);
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
    List<ComponentInfoWithSource> components,
  ) {
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
          '        instance.${field.fieldName} = get<${field.type}>();',
        );
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
