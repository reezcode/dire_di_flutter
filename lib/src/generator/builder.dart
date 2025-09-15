import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'di_generator.dart';
import 'dire_di_builder.dart';

/// Main DI builder (mirrors-free, recommended)
Builder diMirrorsFreeBuilder(BuilderOptions options) =>
    const DireDiAggregatingBuilder();

/// Legacy builder (opt-in only, uses source_gen with dart:mirrors)
Builder diLegacyBuilder(BuilderOptions options) =>
    LibraryBuilder(DiGenerator(), generatedExtension: '.dire_di.dart');
