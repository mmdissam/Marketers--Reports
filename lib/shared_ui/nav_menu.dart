import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/auth/login.dart';
import 'package:marketers_reports/reports/admin_home.dart';

import '../auth/register.dart';

Widget drawer(context) {
  return Drawer(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ListTile(
            title: Text(
              'REGISTER',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(Icons.add_box, size: 30),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RegisterScreen()));
            }),
        ListTile(
            title: Text(
              'All Users',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(Icons.home, size: 30),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminHome()));
            }),
        ListTile(
          title: Text(
            'LOGOUT',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(Icons.exit_to_app,size: 30),
          onTap: () async {
            FirebaseAuth.instance.signOut().then((_) {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            });
          },
        ),
      ],
    ),
  );
}
