import 'package:dire_di_flutter/dire_di.dart';
import 'package:flutter/material.dart';

import 'app_module.dire_di.dart';
import 'ui/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI container with all dependencies
  await DiCore.initialize((container) {
    container.registerGeneratedDependencies();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Dire DI Flutter Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
      );
}
