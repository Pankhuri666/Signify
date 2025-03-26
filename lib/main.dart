import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:signify/pages/sightify_asl_page.dart';
import 'package:signify/passwords.dart';
import 'package:signify/themes/dark_mode.dart';
import 'package:signify/themes/light_mode.dart';

void main() {

  Gemini.init(
    apiKey: GEMINI_KEY
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightMode,
      darkTheme: darkMode,
      home: SightifyASLPage(),
    );
  }
}