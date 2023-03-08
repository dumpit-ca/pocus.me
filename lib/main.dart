import 'package:flutter/material.dart';
import 'package:pocusme/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Timer',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              actionsIconTheme:
                  IconThemeData(color: Colors.green[600], size: 27))),
      home: const MainScreen(),
    );
  }
}
