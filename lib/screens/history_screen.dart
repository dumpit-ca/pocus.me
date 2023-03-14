import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');
  final Query _tasklist = FirebaseFirestore.instance
      .collection('tasks')
      .where('done', isEqualTo: true);

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.green[300]));
  }

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
              "Finished",
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
                          margin: const EdgeInsets.all(10),
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
                          ),
                        );
                      });
                }
                return Center(child: CircularProgressIndicator());
              }),
        ));
  }
}
