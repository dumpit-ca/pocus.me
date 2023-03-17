import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocusme/column_builder.dart';
import 'package:pocusme/data/userdata.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pocusme/graph/bar_data.dart';
import 'package:pocusme/graph/getHistory.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  getHistory _getHistory = getHistory();
  List<double> totals = [];
  double max = 10.0;

  BarData myBarData = BarData(
    sunAmount: 0,
    monAmount: 0,
    tueAmount: 0,
    wedAmount: 0,
    thuAmount: 0,
    friAmount: 0,
    satAmount: 0,
  );

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

  Future<void> initializeData() async {
    totals = await _getHistory.getPastWeekTotals();
    Future.delayed(const Duration(milliseconds: 1000), () {
      myBarData = BarData(
        sunAmount: totals[0],
        monAmount: totals[1],
        tueAmount: totals[2],
        wedAmount: totals[3],
        thuAmount: totals[4],
        friAmount: totals[5],
        satAmount: totals[6],
      );
    });

    double maxYaxis =
        totals.reduce((value, element) => value > element ? value : element);

    setState(() {
      if (maxYaxis > 10) {
        max = maxYaxis + 1;
      }
      myBarData.InitializeBarData();
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
    initializeData();
    myBarData.InitializeBarData();
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20, width: MediaQuery.of(context).size.width),
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
              SizedBox(height: 20),
              SizedBox(
                height: 200,
                width: 350,
                child: BarChart(BarChartData(
                  maxY: max,
                  minY: 0,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getBottomTitles,
                      ),
                    ),
                  ),
                  barGroups: myBarData.barData
                      .map((data) => BarChartGroupData(
                            x: data.x,
                            barRods: [
                              BarChartRodData(
                                  toY: data.y,
                                  color: Color.fromRGBO(40, 182, 126, 1),
                                  width: 25,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: max,
                                    color: Colors.grey[300],
                                  )),
                            ],
                          ))
                      .toList(),
                )),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text('Number of Tasks'),
              ),
              SizedBox(height: 20),
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

Widget getBottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  late Widget texts;
  String day7 = DateFormat('E').format(DateTime.now()).toString();
  String day6 = DateFormat('E')
      .format(DateTime.now().subtract(Duration(days: 1)))
      .toString();
  String day5 = DateFormat('E')
      .format(DateTime.now().subtract(Duration(days: 2)))
      .toString();
  String day4 = DateFormat('E')
      .format(DateTime.now().subtract(Duration(days: 3)))
      .toString();
  String day3 = DateFormat('E')
      .format(DateTime.now().subtract(Duration(days: 4)))
      .toString();
  String day2 = DateFormat('E')
      .format(DateTime.now().subtract(Duration(days: 5)))
      .toString();
  String day1 = DateFormat('E')
      .format(DateTime.now().subtract(Duration(days: 6)))
      .toString();

  switch (value.toInt()) {
    case 0:
      texts = Text(day1, style: style);
      break;
    case 1:
      texts = Text(day2, style: style);
      break;
    case 2:
      texts = Text(day3, style: style);
      break;
    case 3:
      texts = Text(day4, style: style);
      break;
    case 4:
      texts = Text(day5, style: style);
      break;
    case 5:
      texts = Text(day6, style: style);
      break;
    case 6:
      texts = Text(day7, style: style);
      break;
  }

  return SideTitleWidget(child: texts, axisSide: meta.axisSide);
}
