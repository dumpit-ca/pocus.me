import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocusme/column_builder.dart';
import 'package:pocusme/data/userdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      .where('user', isEqualTo: UserData().getUserId())
      .where('done', isEqualTo: false);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (_taskController == null ||
                                _taskController.text.trim().isEmpty) {
                              return 'Please enter a task name';
                            }
                            return null;
                          },
                          controller: _taskController,
                          decoration: const InputDecoration(
                            labelText: 'Task',
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (_timeController == null ||
                                _timeController.text.isEmpty) {
                              return 'Please enter a number';
                            } else if (_timeController == '0') {
                              return 'Please enter a number greater than 0';
                            } else if (double.tryParse(_timeController.text)! >
                                180) {
                              return 'Please enter a number less than 3 hours (180mins)';
                            }
                            return null;
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          controller: _timeController,
                          decoration: const InputDecoration(
                            labelText: 'Time (in minutes)',
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (_dateController == null ||
                                _dateController.text.isEmpty) {
                              return 'Please enter a date';
                            }
                            return null;
                          },
                          controller:
                              _dateController, //editing controller of this TextField
                          decoration: InputDecoration(
                              icon: Icon(
                                  Icons.calendar_today), //icon of text field
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
                            if (_formKey.currentState!.validate()) {
                              final String task = _taskController.text;
                              final double? time =
                                  (double.tryParse(_timeController.text)! * 60);
                              final date = _dateController.text;
                              if (time != null) {
                                await _tasks.add({
                                  'user': UserData().getUserId(),
                                  'task': task,
                                  'time': time,
                                  'date': date,
                                  'done': false,
                                  'break': false
                                });
                                _taskController.clear();
                                _dateController.clear();
                                _timeController.clear();
                              }
                            }
                          },
                        ),
                      ]),
                )),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (_taskController == null ||
                                _taskController.text.trim().isEmpty) {
                              return 'Please enter a task name';
                            }
                            return null;
                          },
                          controller: _taskController,
                          decoration: const InputDecoration(
                            labelText: 'Task',
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (_timeController == null ||
                                _timeController.text.isEmpty) {
                              return 'Please enter a number';
                            } else if (_timeController == '0') {
                              return 'Please enter a number greater than 0';
                            } else if (double.tryParse(_timeController.text)! >
                                180) {
                              return 'Please enter a number less than 3 hours (180mins)';
                            }
                            return null;
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          controller: _timeController,
                          decoration: const InputDecoration(
                            labelText: 'Time (in minutes)',
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (_dateController == null ||
                                _dateController.text.isEmpty) {
                              return 'Please enter a date';
                            }
                            return null;
                          },
                          controller:
                              _dateController, //editing controller of this TextField
                          decoration: InputDecoration(
                              icon: Icon(
                                  Icons.calendar_today), //icon of text field
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
                            if (_formKey.currentState!.validate()) {
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
                            }
                          },
                        ),
                      ]),
                )),
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
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Pending Tasks",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: StreamBuilder(
                      stream: _tasklist.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
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
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                      title: Text(documentSnapshot.get('task'),
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(28, 76, 78, 1),
                                              fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                          ((documentSnapshot.get('time')! / 60)
                                                      .round())
                                                  .toString() +
                                              ' minutes · ' +
                                              documentSnapshot.get('date'),
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(28, 76, 78, 1),
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
                )
              ]),
        ));
  }
}
