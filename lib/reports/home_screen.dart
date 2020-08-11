import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/auth/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _user;
  String _error;
  bool _hasError = false;
  bool _isLoading = true;
  String _name;

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
          _name = snapshotQuery.documents[0]['name'];
          _user = user.uid;
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

  @override
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
              : (_hasError ? _errorMessage(context, _error) : Text(_name)),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: Center(
            child: ListTile(
              title: Text('LOGOUT'),
              trailing: Icon(Icons.exit_to_app),
              onTap: () async {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              },
            ),
          ),
        ),
        body: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: _isLoading
          ? _loading(context)
          : (_hasError
              ? _errorMessage(context, _error)
              : _streamContent(context)),
    );
  }

  Widget _streamContent(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('reports')
          .where('user_id', isEqualTo: _user)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _errorMessage(context, 'No connection is made');
            break;
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return _errorMessage(context, snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return _errorMessage(context, 'No Data');
            }
            return _drawScreen(context, snapshot.data);
            break;
        }
        return null;
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

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return ListView.builder(
      itemCount: data.documents.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          child: ListTile(
            title: Text(
              data.documents[position]['clientName'],
            ),
          ),
        );
      },
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
