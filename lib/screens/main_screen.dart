import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:pocusme/screens/about_me_screen.dart';
import 'package:pocusme/screens/history_screen.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocusme/column_builder.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late double defaultValue = 300;
  late double lastValue = 0;
  late String currentTaskId = '';
  late String currentTaskInfo = '';
  late String currentTaskMin = '';
  bool isStarted = false;
  int focusedMins = 0;
  double value = 300;

  late Timer _timer;

  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');
  Query _today = FirebaseFirestore.instance
      .collection('tasks')
      .where('done', isEqualTo: false)
      .where('date',
          isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  void _update() async {
    if (currentTaskId != '') {
      await _tasks.doc(currentTaskId).update({'done': true});
      setState(() {
        currentTaskId = '';
        currentTaskInfo = '';
        currentTaskMin = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.green[300]));
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
            _update();
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
            child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Center(
                          child: SizedBox(
                            width: 300,
                            height: 300,
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
                                    size: 300,
                                    angleRange: 360,
                                    startAngle: 270,
                                  ),
                                  onChange: (newValue) {
                                    setState(() {
                                      value = newValue;
                                      currentTaskId = '';
                                    });
                                  },
                                  innerWidget: (double newValue) {
                                    return Container(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Ready to Focus?",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        Text(
                                          "${(value ~/ 3600).toInt().toString().padLeft(2, '0')}:${((value - (3600 * (value ~/ 3600))) ~/ 60).toInt().toString().padLeft(2, '0')}:${(value % 60).toInt().toString().padLeft(2, '0')}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 46,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            IconButton(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 0),
                                                onPressed: () {
                                                  setState(() {
                                                    if (!isStarted) {
                                                      isStarted = true;
                                                      startTimer();
                                                    } else {
                                                      _timer.cancel();
                                                      isStarted = false;
                                                    }
                                                  });
                                                },
                                                icon: isStarted
                                                    ? Icon(
                                                        Icons
                                                            .pause_circle_filled,
                                                        size: 50,
                                                        color:
                                                            Colors.green[900],
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .play_circle_filled,
                                                        size: 50,
                                                        color:
                                                            Colors.green[900],
                                                      )),
                                            IconButton(
                                                padding: EdgeInsets.fromLTRB(
                                                    5, 10, 0, 0),
                                                onPressed: () {
                                                  setState(() {
                                                    value = lastValue;
                                                    _timer.cancel();
                                                    isStarted = false;
                                                  });
                                                },
                                                icon: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons
                                                          .replay_circle_filled,
                                                      color: Colors.green[900],
                                                      size: 50,
                                                    ))),
                                          ],
                                        )
                                      ],
                                    ));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Center(
                  child: Text(
                      currentTaskInfo == ''
                          ? "Choose a Task!"
                          : currentTaskInfo,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
                ),
                Center(
                  child: Text(
                      currentTaskMin == ''
                          ? "Scheduled Tasks for Today"
                          : currentTaskMin,
                      style: TextStyle(fontSize: 15)),
                )
              ]),
            ),
            StreamBuilder(
                stream: _today.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData) {
                    return ColumnBuilder(
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                    color: Colors.grey[300]!, width: 1)),
                            margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
                            child: ListTile(
                                title: Text(documentSnapshot.get('task'),
                                    style: TextStyle(
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    (documentSnapshot.get('time')! / 60)
                                            .toString() +
                                        ' minutes',
                                    style: TextStyle(
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.w400)),
                                trailing: SizedBox(
                                  width: 50,
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              value =
                                                  documentSnapshot.get('time');
                                              isStarted = true;
                                              lastValue =
                                                  documentSnapshot.get('time');
                                              currentTaskId =
                                                  documentSnapshot.id;
                                              currentTaskInfo =
                                                  documentSnapshot.get('task');
                                              currentTaskMin = (documentSnapshot
                                                              .get('time')! /
                                                          60)
                                                      .toString() +
                                                  ' minutes';
                                              startTimer();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.play_circle_fill,
                                            size: 30,
                                            color: Colors.green[900],
                                          )),
                                    ],
                                  ),
                                )),
                          );
                        });
                  }
                  return Center(child: CircularProgressIndicator());
                }),
            Container(
              padding: EdgeInsets.only(bottom: 30),
            ),
          ],
        )));
  }
}
