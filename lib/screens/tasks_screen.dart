import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocusme/screens/main_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');
  Query _tasklist = FirebaseFirestore.instance
      .collection('tasks')
      .where('done', isNotEqualTo: true);

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  void initState() {
    _dateController.text = DateTime.now().toString();
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _taskController.text = documentSnapshot['task'];
      _timeController.text = documentSnapshot['time'].toString();
      _dateController.text = documentSnapshot['date'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        labelText: 'Task',
                      ),
                    ),
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (in minutes)',
                      ),
                    ),
                    TextField(
                      controller:
                          _dateController, //editing controller of this TextField
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Enter Date" //label text of field
                          ),
                      readOnly:
                          true, //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime
                                .now(), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            _dateController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () async {
                        final String task = _taskController.text;
                        final double? time =
                            (double.tryParse(_timeController.text)! * 60);
                        final date = _dateController.text;
                        if (time != null) {
                          await _tasks.add({
                            'task': task,
                            'time': time,
                            'date': date,
                            'done': false
                          });
                          _taskController.clear();
                          _dateController.clear();
                          _timeController.clear();
                        }
                      },
                    ),
                  ]),
            ),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _taskController.text = documentSnapshot['task'];
      _timeController.text = (documentSnapshot['time']! / 60).toString();
      _dateController.text = documentSnapshot['date'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(
                        labelText: 'Task',
                      ),
                    ),
                    TextField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (in minutes)',
                      ),
                    ),
                    TextField(
                      controller:
                          _dateController, //editing controller of this TextField
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Enter Date" //label text of field
                          ),
                      readOnly:
                          true, //set it true, so that user will not able to edit text
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime
                                .now(), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2101));

                        if (pickedDate != null) {
                          print(
                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          print(
                              formattedDate); //formatted date output using intl package =>  2021-03-16
                          //you can implement different kind of Date Format here according to your requirement

                          setState(() {
                            _dateController.text =
                                formattedDate; //set output date to TextField value.
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () async {
                        final String task = _taskController.text;
                        final double? time =
                            (double.tryParse(_timeController.text)! * 60);
                        final date = _dateController.text;
                        if (time != null) {
                          await _tasks.doc(documentSnapshot!.id).update(
                              {'task': task, 'time': time, 'date': date});
                          _taskController.clear();
                          _dateController.clear();
                          _timeController.clear();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ]),
            ),
          );
        });
  }

  Future<void> _delete(String taskId) async {
    await _tasks.doc(taskId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task Deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _taskController.clear();
            _dateController.clear();
            _timeController.clear();
            _create();
          },
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.green[600]),
          title: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              "Tasks",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 30,
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: StreamBuilder(
              stream: _tasklist.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                  color: Colors.grey[300]!, width: 1)),
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                              title: Text(documentSnapshot.get('task'),
                                  style: TextStyle(
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  (documentSnapshot.get('time')! / 60)
                                          .toString() +
                                      ' minutes · ' +
                                      documentSnapshot.get('date'),
                                  style: TextStyle(
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.w400)),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          _update(documentSnapshot);
                                        },
                                        icon: const Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          _delete(documentSnapshot.id);
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ],
                                ),
                              )),
                        );
                      });
                }
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
