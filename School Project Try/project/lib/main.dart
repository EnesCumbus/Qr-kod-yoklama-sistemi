import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/firebase_options.dart';
import 'package:project/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/SSS": (context) => SSS(),
        // Diğer rotalar...
      },
      debugShowCheckedModeBanner: false,
      title: 'Flutter Context Buildings',
      theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 19, 65, 111)),
          useMaterial3: false),
      home: LoginPage(),
    );
  }
}
