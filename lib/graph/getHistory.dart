import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pocusme/data/userdata.dart';

class getHistory {
  Query _tasks = FirebaseFirestore.instance
      .collection('tasks')
      .where('user', isEqualTo: UserData().getUserId())
      .where('break', isEqualTo: false)
      .where('done', isEqualTo: true);
  DateTime now = DateTime.now();

  Future<double> dateTotal(DateTime date) async {
    final reference =
        _tasks.where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(date));

    QuerySnapshot snapshot = await reference.get();

    double total = 0.0;
    double num = 0.0;
    for (DocumentSnapshot doc in snapshot.docs) {
      total += (doc.get('time')! / 60);
      num += 1.0;
    }
    return num;
  }

  Future getPastWeekTotals() async {
    List<double> totals = [];
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      double total = await dateTotal(date);
      totals.add(total);
    }
    print(totals);
    return totals;
  }
}
