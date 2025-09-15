import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'di_generator.dart';
import 'dire_di_builder.dart';

Builder diMirrorsFreeBuilder(BuilderOptions options) =>
    const DireDiAggregatingBuilder();

Builder diLegacyBuilder(BuilderOptions options) =>
    LibraryBuilder(DiGenerator(), generatedExtension: '.dire_di.dart');
