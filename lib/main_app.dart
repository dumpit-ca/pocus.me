import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocusme/auth/register.dart';
import 'package:pocusme/tab_navigator.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "Tasks", "History", "About"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Tasks": GlobalKey<NavigatorState>(),
    "History": GlobalKey<NavigatorState>(),
    "About": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white);

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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pocus.me',
        theme: ThemeData(
            fontFamily: 'Lexend',
            appBarTheme: AppBarTheme(
                actionsIconTheme:
                    IconThemeData(color: Colors.green[600], size: 27))),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(children: [
              Image.asset(
                "assets/logo.png",
                width: 40,
                height: 40,
              ),
              Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      Text('pocus.me',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 19)),
                      Text('your time, well spent.',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 9)),
                    ],
                  ))
            ]),
          ),
          body: _buildMainNav(context),
        ));
  }

  Widget _buildMainNav(BuildContext context) {
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
          _buildOffstageNavigator("Tasks"),
          _buildOffstageNavigator("History"),
          _buildOffstageNavigator("About"),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Color.fromRGBO(13, 19, 33, 1),
          unselectedItemColor: Color.fromRGBO(211, 221, 223, 1),
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
              icon: Icon(Icons.check_box),
              label: 'Tasks',
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
        // userId: super.userId,
      ),
    );
  }
}
