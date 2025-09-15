import 'package:build/build.dart';

import 'src/generator/builder.dart' as gen;

Builder diBuilder(BuilderOptions options) => gen.diBuilder(options);

Builder diAggregatingBuilder(BuilderOptions options) => gen.diAggregatingBuilder(options);

Builder diMirrorsFreeBuilder(BuilderOptions options) => gen.diMirrorsFreeBuilder(options);
