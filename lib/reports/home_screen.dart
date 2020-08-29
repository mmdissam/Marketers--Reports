import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketers_reports/auth/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseUser _user;
  String _error;
  bool _hasError = false;
  bool _isLoading = true;
  String _name;
  double total = 0;
  List<double> postList  =[];

  @override
  void initState() {
    super.initState();
    _prepareData().then((_) =>{
      queryValues()
    });
  }

  Future<FirebaseUser> _prepareData() async {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('profiles')
          .where('user_id', isEqualTo: user.uid)
          .getDocuments()
          .then((snapshotQuery) {
        setState(() {
          _name = snapshotQuery.documents[0]['name'];
          _user = user;
          _hasError = false;
          _isLoading = false;
        });
      });
      return user;
    }).catchError((error) {
      setState(() {
        _hasError = true;
        _error = error.toString();
      });
      return null;
    });
    return null;
  }

  void queryValues() {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance
          .collection('reports').where('user_id', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        double tempTotal = snapshot.documents.fold(
            0, (tot, doc) => tot + doc.data['total']);
        setState(() {
          total = tempTotal;
        });
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
    return _isLoading
        ? _loading(context)
        : (_hasError
            ? _errorMessage(context, _error)
            : _streamContent(context));
  }

  Widget _streamContent(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('reports')
          .where('user_id', isEqualTo: _user.uid)
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
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: data.documents.length,
        itemBuilder: (BuildContext context, int position) {
          Timestamp timeStamp = data.documents[position]['history'];
          DateTime dateTime = timeStamp.toDate();
          return Column(
            children: <Widget>[
              Card(
                child: Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _columnOfReport(context, 'Date',
                          DateFormat('yyyy-MM-dd').format(dateTime)),
                      _dividing(context),
                      _columnOfReport(context, 'Client Name',
                          data.documents[position]['clientName']),
                      _dividing(context),
                      _columnOfReport(
                          context, 'Phone', data.documents[position]['phone']),
                      _dividing(context),
                      _columnOfReport(context, 'Product Name',
                          data.documents[position]['productName']),
                      _dividing(context),
                      _columnOfReport(context, 'Quantity',
                          data.documents[position]['quantity']),
                      _dividing(context),
                      _columnOfReport(
                          context, 'Price', data.documents[position]['price']),
                      _dividing(context),
                      _columnOfReport(context, 'Delivery Price',
                          data.documents[position]['deliveryPrice']),
                      _dividing(context),
                      _columnOfReport(context, 'Total',
                          '${data.documents[position]['total']}'),
                      _dividing(context),
                      _columnOfReport(context, 'Net Profit',
                          '${data.documents[position]['netProfit']}'),
                      _dividing(context),
                      _columnOfReport(context, 'Comment',
                          data.documents[position]['comments']),
                    ],
                  ),
                ),
              ),
              (position + 1 == data.documents.length)
                  ? _summaryReport(context, data.documents.length)
                  : Container(),
            ],
          );
        },
      ),
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _dividing(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 50,
      width: 1,
      color: Colors.black,
    );
  }

  Widget _columnOfReport(BuildContext context, String title, String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _title(context, title),
        Spacer(flex: 1),
        Text(details),
      ],
    );
  }

  Widget _title(BuildContext context, String title) {
    return RichText(
      text: TextSpan(
        text: '$title\n',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: '----------------',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _summaryReport(BuildContext context, int numOfReport) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.green.shade100,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _columnOfReport(
                context, 'Number of operations', numOfReport.toString()),
            _dividing(context),
            _columnOfReport(
                context, 'Total Earnings', total.toString()),
          ],
        ),
      ),
    );
  }
}
