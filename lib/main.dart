import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocusme/auth/register.dart';
import 'package:pocusme/auth/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocusme/data/userdata.dart';
import 'package:pocusme/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final storage = FlutterSecureStorage();
  String? userid = await storage.read(key: 'userId');
  String? username = await storage.read(key: 'userFname');
  UserData userData = UserData();

  if ((username != null) && (userid != null)) {
    userData.userSetId = userid;
    userData.userSetFname = username;
    runApp(const MainApp());
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pocus.me',
        theme: ThemeData(
            fontFamily: 'Lexend',
            appBarTheme: AppBarTheme(
                actionsIconTheme:
                    IconThemeData(color: Colors.green[600], size: 27))),
        home: Scaffold(
          body: LoginPage(),
        ));
  }
}
