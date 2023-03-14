import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({Key? key}) : super(key: key);

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.green[600]),
        title: Padding(
          padding: EdgeInsets.only(top: 10.0),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
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
                  fontWeight: FontWeight.w500,
                  color: Colors.green[900],
                ),
              ),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.grey[300]!, width: 1)),
                  margin: EdgeInsets.fromLTRB(15, 20, 15, 10),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        child: ListTile(
                            title: Text("Cassandra Dumpit",
                                style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text("UI/UX Developer",
                                style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w400)),
                            trailing: SizedBox(width: 50)),
                      )
                    ],
                  )),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.grey[300]!, width: 1)),
                  margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        child: ListTile(
                            title: Text("Jhon Louie De Leon",
                                style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text("Lead Designer",
                                style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w400)),
                            trailing: SizedBox(width: 50)),
                      )
                    ],
                  )),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.grey[300]!, width: 1)),
                  margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        child: ListTile(
                            title: Text("Frank Vincent Gesmundo",
                                style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text("Lead Developer",
                                style: TextStyle(
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w400)),
                            trailing: SizedBox(width: 50)),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
