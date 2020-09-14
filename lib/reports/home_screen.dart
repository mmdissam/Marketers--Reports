import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
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
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();

  List<double> postList = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
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
          .collection('reports')
          .where('user_id', isEqualTo: user.uid)
          .where('history', isGreaterThanOrEqualTo: _start)
          .where('history', isLessThanOrEqualTo: _end)
          .snapshots()
          .listen((snapshot) {
        double tempTotal =
            snapshot.documents.fold(0, (tot, doc) => tot + doc.data['total']);
        setState(() {
          total = tempTotal;
        });
      });
    });
  }

  Future displayDateRange(BuildContext context) async {
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: _start,
        initialLastDate: _end,
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2030));
    if (picked != null && picked.length == 2) {
      setState(() {
        _start = picked[0];
        _end = picked[1].add(Duration(days: 1));
      });
    }
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
          actions: <Widget>[
            Center(
              child: FlatButton.icon(
                icon: Icon(Icons.search, color: Colors.white),
                label: Text('بحث', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await displayDateRange(context);
                  queryValues();
                },
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Center(
            child: ListTile(
              title: Text(
                'تسجيل خروج',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.exit_to_app, size: 30),
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
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('reports')
          .where('user_id', isEqualTo: _user.uid)
          .where('history', isGreaterThanOrEqualTo: _start)
          .where('history', isLessThanOrEqualTo: _end)
          .orderBy('history', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            } else if (snapshot.data.documents.length <= 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                    child: Text(
                  'لا يوجد بيانات في الفترة المحددة الرجاء اختيار فترة أخرى من أيقونة البحث',
                  style: TextStyle(fontSize: 18, color: Colors.deepOrange),
                )),
              );
            } else {
              return _drawScreen(context, snapshot.data);
            }

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
                  height: 90,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _columnOfReport(context, 'التاريخ',
                          DateFormat('yyyy-MM-dd').format(dateTime)),
                      _dividing(context),
                      _columnOfReport(context, 'اسم الزبون',
                          data.documents[position]['clientName']),
                      _dividing(context),
                      _columnOfReport(
                          context, 'الهاتف', data.documents[position]['phone']),
                      _dividing(context),
                      _columnOfReport(context, 'اسم الصنف',
                          data.documents[position]['productName']),
                      _dividing(context),
                      _columnOfReport(context, 'الكمية',
                          data.documents[position]['quantity']),
                      _dividing(context),
                      _columnOfReport(
                          context, 'السعر', data.documents[position]['price']),
                      _dividing(context),
                      _columnOfReport(context, 'التوصيل',
                          data.documents[position]['deliveryPrice']),
                      _dividing(context),
                      _columnOfReport(context, 'المجموع',
                          '${data.documents[position]['total']}'),
                      _dividing(context),
                      _columnOfReport(context, 'ربح المسوّق',
                          '${data.documents[position]['netProfit']}'),
                      _dividing(context),
                      _columnOfReport(context, 'تقرير',
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _columnOfReport(context, 'عدد العمليات', numOfReport.toString()),
            _dividing(context),
            _columnOfReport(context, 'إجمالي ربح المسوّق', total.toString()),
          ],
        ),
      ),
    );
  }
}
