import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/reports/new_report.dart';
import 'package:marketers_reports/reports/report_marketers_for_admin.dart';
import 'package:marketers_reports/shared_ui/nav_menu.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String _error;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('profiles')
          .where('user_id', isEqualTo: user.uid)
          .getDocuments()
          .then((snapshotQuery) {
        setState(() {
          _hasError = false;
          _isLoading = false;
        });
      });
    }).catchError((error) {
      setState(() {
        _hasError = true;
        _error = error.toString();
      });
    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isLoading
              ? _loading(context)
              : (_hasError
                  ? _errorMessage(context, _error)
                  : Text('أبو كنان',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => NewReport()));
            },
            child: Icon(Icons.add)),
        drawer: drawer(context),
        body: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return _isLoading
        ? _loading(context)
        : (_hasError
            ? _errorMessage(context, _error)
            : _streamContent(context));
  }

  Widget _streamContent(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('profiles').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _errorMessage(context, 'لا يوجد اتصال');
            break;
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return _errorMessage(context, snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return _errorMessage(context, 'لا يوجد بيانات');
            }
            return _drawScreen(context, snapshot.data);
            break;
        }
        return null;
      },
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: data.documents.length,
      itemBuilder: (BuildContext context, int position) {
        return InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ReportMarketersForAdmin(
                  userId: data.documents[position]['user_id']))),
          child: Card(
            child: ListTile(
              title: Text(
                data.documents[position]['name'],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _errorMessage(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
