import 'package:build/build.dart';

import 'src/generator/builder.dart' as gen;

/// Main DI builder (mirrors-free, recommended)
Builder diMirrorsFreeBuilder(BuilderOptions options) =>
    gen.diMirrorsFreeBuilder(options);

/// Legacy builder (opt-in only, uses source_gen with dart:mirrors)
Builder diLegacyBuilder(BuilderOptions options) => gen.diLegacyBuilder(options);
