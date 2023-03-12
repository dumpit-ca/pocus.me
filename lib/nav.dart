import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocusme/screens/main_screen.dart';
import 'package:pocusme/controllers/history_controller.dart';
import 'package:pocusme/models/history_model.dart';
import 'package:pocusme/screens/about_me_screen.dart';
import 'package:pocusme/screens/history_screen.dart';
import 'package:pocusme/tab_navigator.dart';

class Nav extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NavState();
}

class NavState extends State<Nav> {
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "Pending", "History", "About"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Pending": GlobalKey<NavigatorState>(),
    "History": GlobalKey<NavigatorState>(),
    "About": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Home") {
            _selectTab("Home", 1);

            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator("Home"),
          _buildOffstageNavigator("Pending"),
          _buildOffstageNavigator("History"),
          _buildOffstageNavigator("About"),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blueAccent,
          onTap: (int index) {
            _selectTab(pageKeys[index], index);
          },
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pending),
              label: 'Pending',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'About',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}
