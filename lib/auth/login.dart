import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocusme/auth/register.dart';
import 'package:pocusme/data/userdata.dart';
import 'package:pocusme/main_app.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> submitLoginForm() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      String userId = userCredential.user!.uid;

      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((snapshot) async {
        if (await snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data();
          UserData userData = UserData();
          userData.userSetId = userId;
          userData.userSetFname = await (data!['fname']);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are being logged in...'),
            ),
          );

          if (await (data['fname']) != null) {
            final storage = FlutterSecureStorage();
            await storage.write(key: 'userId', value: userId);
            await storage.write(key: 'userFname', value: (data['fname']));

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainApp()),
            );
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User does not exist!'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email or password is incorrect!'),
          ),
        );
      }
    } catch (e) {
      // Handle other errors
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: 200,
                child: Center(
                    child: Image.asset(
                  "assets/logo.png",
                  width: 40,
                  height: 40,
                )),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
              ),
            ]),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a valid email.';
                          } else if (!value.contains('@') ||
                              !value.contains('.')) {
                            return 'Please enter a valid email.';
                          }
                          return null;
                        },
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(28, 76, 78, 1),
                                width: 2.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a valid password.';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }
                        },
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(28, 76, 78, 1),
                                width: 2.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(28, 76, 78, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  submitLoginForm();
                }
              },
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Login', style: TextStyle(fontSize: 18))),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => RegisterPage()));
              },
              child: new Text("Don't have an Account? Register Here!"),
            )
          ],
        ),
      ),
    );
  }
}
