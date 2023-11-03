import 'package:flutter/material.dart';
import 'package:pocusme/screens/about_me_screen.dart';
import 'package:pocusme/screens/history_screen.dart';
import 'package:pocusme/screens/main_screen.dart';
import 'package:pocusme/screens/notes_screen.dart';
import 'package:pocusme/screens/tasks_screen.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {
    Widget child = MainScreen();

    if (tabItem == 'Home')
      child = MainScreen();
    else if (tabItem == 'Tasks')
      child = TaskScreen();
    else if (tabItem == 'Notes')
      child = NotesScreen();
    else if (tabItem == 'History')
      child = HistoryScreen();
    else if (tabItem == 'About') child = AboutMeScreen();

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
