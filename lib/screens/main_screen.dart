import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocusme/column_builder.dart';
import 'package:pocusme/data/userdata.dart';

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

  UserData userData = UserData();

  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  Query _today = FirebaseFirestore.instance
      .collection('tasks')
      .where('user', isEqualTo: UserData().getUserId())
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
        SystemUiOverlayStyle(statusBarColor: Color.fromRGBO(40, 182, 126, 1)));
  }

  void addBreak() async {
    await _tasks.add({
      'user': UserData().getUserId(),
      'task': 'Break Mode',
      'time': focusedMins,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'done': true
    });
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

            if (currentTaskId != '') {
              _update();
            } else {
              addBreak();
            }
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
            SizedBox(height: 20),
            Container(
              child: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Welcome!",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            Text(userData.getFname()),
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
                                  max: 10800,
                                  appearance: CircularSliderAppearance(
                                    customWidths: CustomSliderWidths(
                                      trackWidth: 15,
                                      handlerSize: 20,
                                      progressBarWidth: 15,
                                      shadowWidth: 0,
                                    ),
                                    customColors: CustomSliderColors(
                                      trackColor:
                                          Color.fromRGBO(40, 182, 126, 1),
                                      progressBarColor:
                                          Color.fromRGBO(28, 76, 78, 1),
                                      hideShadow: true,
                                      dotColor: Color.fromRGBO(28, 76, 78, 1),
                                    ),
                                    size: 300,
                                    angleRange: 360,
                                    startAngle: 270,
                                  ),
                                  onChange: (newValue) {
                                    setState(() {
                                      value = newValue;
                                      if (currentTaskId != '') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Modifying your focus time will set to break mode.'),
                                          ),
                                        );
                                      }
                                      if (isStarted) {
                                        _timer.cancel();
                                        isStarted = false;
                                      }
                                      currentTaskId = '';
                                      currentTaskInfo = '';
                                      currentTaskMin = '';
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
                                                        color: Color.fromRGBO(
                                                            40, 182, 126, 1),
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .play_circle_filled,
                                                        size: 50,
                                                        color: Color.fromRGBO(
                                                            40, 182, 126, 1),
                                                      )),
                                            IconButton(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 0),
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
                                                      color: Color.fromRGBO(
                                                          40, 182, 126, 1),
                                                      size: 50,
                                                    ))),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 10, 0, 0),
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                  Color>(
                                                        (Set<MaterialState>
                                                            states) {
                                                          if (currentTaskId ==
                                                              '') {
                                                            // Change the color darkness when the button is pressed
                                                            return Color
                                                                .fromRGBO(28,
                                                                    76, 78, 1);
                                                          } else {
                                                            // Use the default color when the button is not pressed
                                                            return Color
                                                                .fromRGBO(
                                                                    40,
                                                                    182,
                                                                    126,
                                                                    1);
                                                          }
                                                        },
                                                      ),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                      ))),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (isStarted) {
                                                        _timer.cancel();
                                                      }
                                                      isStarted = false;

                                                      value = defaultValue;
                                                      if (currentTaskId != '') {
                                                        currentTaskId = '';
                                                        currentTaskInfo = '';
                                                        currentTaskMin = '';
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Set to Break Mode, Task Cleared from Timer.'),
                                                          ),
                                                        );
                                                      } else if (currentTaskId ==
                                                          '') {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Already in Break Mode. No Task Selected.'),
                                                          ),
                                                        );
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text("Break"),
                                                          Text("Mode"),
                                                        ]),
                                                  )),
                                            )
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
                                        color: Color.fromRGBO(28, 76, 78, 1),
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    (documentSnapshot.get('time')! / 60)
                                            .toString() +
                                        ' minutes',
                                    style: TextStyle(
                                        color: Color.fromRGBO(28, 76, 78, 1),
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
                                            color:
                                                Color.fromRGBO(28, 76, 78, 1),
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
