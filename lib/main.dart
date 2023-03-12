import 'package:flutter/material.dart';
import 'package:pocusme/screens/main_screen.dart';
import 'package:pocusme/controllers/history_controller.dart';
import 'package:pocusme/models/history_model.dart';
import 'package:pocusme/screens/about_me_screen.dart';
import 'package:pocusme/screens/history_screen.dart';
import 'package:pocusme/nav.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pocus.me',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                actionsIconTheme:
                    IconThemeData(color: Colors.green[600], size: 27))),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(children: [
              Image.asset(
                "assets/logo.png",
                width: 40,
                height: 40,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      Text('pocus.me',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 19)),
                      Text('your time, well spent.',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 9)),
                    ],
                  ))
            ]),
          ),
          body: Nav(),
        ));
  }
}
