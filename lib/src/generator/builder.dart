import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'di_generator.dart';
import 'mirrors_free_builder.dart';

/// Builder for generating dependency injection code (per-file)
Builder diBuilder(BuilderOptions options) =>
    LibraryBuilder(DiGenerator(), generatedExtension: '.dire_di.dart');

/// Mirrors-free aggregating builder (recommended for Flutter/mobile)
Builder diMirrorsFreeBuilder(BuilderOptions options) =>
    const MirrorsFreeAggregatingBuilder();
