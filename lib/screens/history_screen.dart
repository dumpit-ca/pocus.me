import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocusme/column_builder.dart';
import 'package:pocusme/data/userdata.dart';
import 'package:fl_chart/fl_chart.dart';

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
      .where('user', isEqualTo: UserData().getUserId())
      .where('done', isEqualTo: true);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.green[300]));
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Finished Tasks",
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
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(documentSnapshot.get('task'),
                                      style: TextStyle(
                                          color: Color.fromRGBO(28, 76, 78, 1),
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      ((documentSnapshot.get('time')! / 60))
                                              .round()
                                              .toString() +
                                          ' minutes · ' +
                                          documentSnapshot.get('date'),
                                      style: TextStyle(
                                          color: Color.fromRGBO(28, 76, 78, 1),
                                          fontWeight: FontWeight.w400)),
                                  trailing: SizedBox(
                                    width: 50,
                                    child: IconButton(
                                        onPressed: () {
                                          _delete(documentSnapshot.id);
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ),
                                ),
                              );
                            });
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              )
            ],
          ),
        ));
  }
}
