import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:restart_app/restart_app.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({Key? key}) : super(key: key);

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "About the App",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          "assets/logo.png",
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "pocus.me",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(28, 76, 78, 1),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(28, 76, 78, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You are being logged out...'),
                            ),
                          );
                          final storage = FlutterSecureStorage();
                          await storage.deleteAll();
                          await FirebaseAuth.instance.signOut().then((value) {
                            Future.delayed(const Duration(milliseconds: 1000),
                                () {
                              Restart.restartApp();
                            });
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Log Out',
                                style: TextStyle(fontSize: 20))),
                      ),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                  color: Colors.grey[300]!, width: 1)),
                          margin: EdgeInsets.fromLTRB(15, 20, 15, 10),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                child: ListTile(
                                    title: Text("Cassandra Dumpit",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text("UI/UX Developer",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
                                            fontWeight: FontWeight.w400)),
                                    trailing: SizedBox(width: 50)),
                              )
                            ],
                          )),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                  color: Colors.grey[300]!, width: 1)),
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                child: ListTile(
                                    title: Text("Jhon Louie De Leon",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text("Lead Designer",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
                                            fontWeight: FontWeight.w400)),
                                    trailing: SizedBox(width: 50)),
                              )
                            ],
                          )),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                  color: Colors.grey[300]!, width: 1)),
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                child: ListTile(
                                    title: Text("Frank Vincent Gesmundo",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text("Lead Developer",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
                                            fontWeight: FontWeight.w400)),
                                    trailing: SizedBox(width: 50)),
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
