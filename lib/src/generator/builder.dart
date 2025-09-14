import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'di_generator.dart';

/// Builder for generating dependency injection code
Builder diBuilder(BuilderOptions options) =>
    LibraryBuilder(DiGenerator(), generatedExtension: '.dire_di.dart');
