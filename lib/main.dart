import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/auth/home_login.dart';
import 'package:marketers_reports/reports/home_screen.dart';
import 'package:marketers_reports/reports/new_report.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Widget homeScreen = HomeLogin();
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  if (user != null) {
    homeScreen =
        user.uid == '1ClqQn53gYZCXvQaZI3eahQDY9E2' ? NewReport() : HomeScreen();
  }

  runApp(MarketersReports(
    home: homeScreen,
  ));
}

class MarketersReports extends StatelessWidget {
  final Widget home;

  const MarketersReports({Key key, this.home}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketers Reports',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.amber,
        accentColor: Colors.amber,
      ),
      home: home,
    );
  }
}
