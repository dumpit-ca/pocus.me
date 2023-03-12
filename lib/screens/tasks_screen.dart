import 'package:flutter/material.dart';
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

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

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
          return Padding(
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
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                    ),
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
                        await _tasks
                            .add({'task': task, 'time': time, 'date': date});
                        _taskController.clear();
                        _timeController.clear();
                      }
                    },
                  ),
                ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
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
      body: StreamBuilder(
          stream: _tasks.snapshots(),
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
                          side: BorderSide(color: Colors.grey[300]!, width: 1)),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                          title: Text(documentSnapshot.get('task'),
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              (documentSnapshot.get('time')! / 60).toString() +
                                  ' minutes',
                              style: TextStyle(
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.w400)),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      // _update(documentSnapshot);
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      // _delete(documentSnapshot.id);
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
    );
  }
}
