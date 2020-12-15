import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:intl/intl.dart';

class ReportMarketersForAdmin extends StatefulWidget {
  final String userId;

  const ReportMarketersForAdmin({Key key, this.userId}) : super(key: key);
  @override
  _ReportMarketersForAdminState createState() =>
      _ReportMarketersForAdminState();
}

class _ReportMarketersForAdminState extends State<ReportMarketersForAdmin> {
  String _error;
  bool _hasError = false;
  bool _isLoading = true;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _name;
  double total = 0;
  int numOfOperation = 0;
  TextStyle _navigationBottomBartextStyle =
      TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

  TextStyle _textStylePirce = TextStyle(color: Colors.black);
  TextStyle _textStyleRow = TextStyle(fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    Firestore.instance
        .collection('profiles')
        .where('user_id', isEqualTo: widget.userId)
        .getDocuments()
        .then((snapshotQuery) {
      setState(() {
        _name = snapshotQuery.documents[0]['name'];
        _hasError = false;
        _isLoading = false;
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
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? _loading(context)
            : (_hasError
                ? _errorMessage(context, _error)
                : Text(
                    _name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
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
      bottomNavigationBar: bottomNavigationBar(),
      body: _content(context),
    );
  }

  Container bottomNavigationBar() {
    return Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        color: Colors.deepOrange,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
              width: 80,
              child: ListTile(
                title: Text('العدد', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  numOfOperation.toString(),
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: ListTile(
                title: Text(
                  'السعر الأصلي',
                  style: _navigationBottomBartextStyle,
                ),
                subtitle: Text(
                  '150000' + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ListTile(
                title: Text('سعر الجملة', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  '1500' + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ListTile(
                title: Text('ربح التاجر', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  '1500' + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: ListTile(
                title:
                    Text('ربح المسوّق', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  '1500' + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
          ],
        ));
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
          .where('user_id', isEqualTo: widget.userId)
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
              numOfOperation = snapshot.data.documents.length;
              return _drawScreen(context, snapshot.data);
            }

            break;
        }
        return null;
      },
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: data.documents.length,
        itemBuilder: (BuildContext context, int position) {
          Timestamp timeStamp = data.documents[position]['history'];
          List numOfItem = data.documents[position]['order_item'];
          DateTime dateTime = timeStamp.toDate();
          return Column(
            children: <Widget>[
              position == 0 ? _rowOfItemOrder(context, position) : Container(),
              InkWell(
                onTap: () {
                  _showMaterialDialog(context, data, position);
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '(' + numOfItem.length.toString() + ')',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              data.documents[position]['clientName'].toString(),
                              softWrap: true,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd')
                                .format(dateTime)
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          RichText(
                              textAlign: TextAlign.center,
                              softWrap: true,
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text:
                                        '${data.documents[position]['netProfit']}\t',
                                    style: TextStyle(
                                      color: Color(0xFF1367B8),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    )),
                                TextSpan(
                                  text: '₪',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ])),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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

  Widget _errorMessage(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  _rowOfItemOrder(BuildContext context, int position) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Text('العدد', style: _textStyleRow),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Text('اسم الزبون', style: _textStyleRow),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 70),
            child: Text('التاريخ', style: _textStyleRow),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Text('ربح المسوّق', style: _textStyleRow),
          ),
        ],
      ),
    );
  }

  _showMaterialDialog(BuildContext context, QuerySnapshot data, int position) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: _drawTitleShowDialog(position),
        elevation: 10,
        titlePadding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 0),
        contentPadding:
            EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Color(0xFFFFFFFF),
        actions: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[],
            ),
          )
        ],
      ),
    );
  }

  Widget _drawTitleShowDialog(int position) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: 'طلبية رقم',
          style: TextStyle(
            color: Color(0xFF191B1D),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          text: "\t\t(${position + 1})",
          style: TextStyle(
            color: Color(0xFF1367B8),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ]),
    );
  }
}
