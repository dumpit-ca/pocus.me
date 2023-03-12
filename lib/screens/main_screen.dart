import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocusme/controllers/history_controller.dart';
import 'package:pocusme/models/history_model.dart';
import 'package:pocusme/screens/about_me_screen.dart';
import 'package:pocusme/screens/history_screen.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late double defaultValue = 300;
  bool isStarted = false;
  int focusedMins = 0;
  double value = 300;
  List<History> listHistory = [];

  late Timer _timer;

  HistoryController historyController = HistoryController();
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Pass this method to the child page.
  void _update(int count) {
    double countd = count + 0.0;
    setState(() => value = countd);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.green[300]));
    HistoryController.init();
  }

  void startTimer() {
    focusedMins = value.toInt();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (value <= 1) {
          setState(() {
            timer.cancel();
            value = defaultValue;
            isStarted = false;
            listHistory = historyController.read("history");
            listHistory.add(
                History(dateTime: DateTime.now(), focusedSecs: focusedMins));
            historyController.save("history", listHistory);
            // print(historyController.read("history"));
          });
        } else {
          setState(() {
            value--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.green[600],
                        size: 35,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (BuildContext context) =>
                                    const AboutMeScreen()));
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.history,
                        color: Colors.green[600],
                        size: 35,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (BuildContext context) =>
                                    const HistoryScreen()));
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: Stack(
                            children: [
                              SleekCircularSlider(
                                initialValue: value,
                                min: 0,
                                max: 5401,
                                appearance: CircularSliderAppearance(
                                  customWidths: CustomSliderWidths(
                                    trackWidth: 15,
                                    handlerSize: 20,
                                    progressBarWidth: 15,
                                    shadowWidth: 0,
                                  ),
                                  customColors: CustomSliderColors(
                                    trackColor: Colors.green[300],
                                    progressBarColor: Colors.green[700],
                                    hideShadow: true,
                                    dotColor: Colors.green[700],
                                  ),
                                  size: 250,
                                  angleRange: 360,
                                  startAngle: 270,
                                ),
                                onChange: (newValue) {
                                  setState(() {
                                    value = newValue;
                                  });
                                },
                                innerWidget: (double newValue) {
                                  return Center(
                                    child: Text(
                                      "${(value ~/ 3600).toInt().toString().padLeft(2, '0')}:${((value - (3600 * (value ~/ 3600))) ~/ 60).toInt().toString().padLeft(2, '0')}:${(value % 60).toInt().toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 46,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (isStarted)
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    color: Colors.transparent,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isStarted) {
                              isStarted = true;
                              startTimer();
                            } else {
                              _timer.cancel();
                              value = defaultValue;
                              isStarted = false;
                            }
                          });
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 3,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                                color: Colors.black.withOpacity(0.2),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isStarted ? "STOP" : "START",
                            style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              value = 600;
                            });
                          },
                          child: Text("Set to 10mins"))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
