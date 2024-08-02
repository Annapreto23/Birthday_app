import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:birthdays/pages/home.dart';
import 'package:birthdays/pages/search.dart';
import 'package:birthdays/pages/birthday_page.dart';  

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Birthday App',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF111111),
      ),
      home: BottomNav(),
    );
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    BirthdayPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 30,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedIconTheme: IconThemeData(size: 40),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedLabelStyle: TextStyle(fontFamily: "gluten"),
          unselectedLabelStyle: TextStyle(fontFamily: "gluten"),
          selectedItemColor: Color(0xFFFFC02E),
          unselectedItemColor: Colors.blueGrey,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/home-icon.png', width: MediaQuery.of(context).size.width / 12),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/search-icon.png', width: MediaQuery.of(context).size.width / 14),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/settings-icon.png', width: MediaQuery.of(context).size.width / 13),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
