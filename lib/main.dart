import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'تقارير المسوّقين',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
        iconTheme: IconThemeData(color: Colors.deepOrange),
        primaryIconTheme: IconThemeData(color: Colors.white),
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      home: home,
      localizationsDelegates: [
        // To make all the widget and Material and my edits change according to the language
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', ''),
      ],
    );
  }
}
