import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:google_fonts/google_fonts.dart';
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
  Color _grayColor = Colors.grey;
  Color _blackColor = Colors.black54;
  int numOfOperation = 0;
  double _netProfit = 0;
  double _totalOriginalPrice = 0;
  double _totalWholesalePrice = 0;
  double _totalSellingPrice = 0;
  double _totalTraderProfit = 0;
  double _totalMarketerProfit = 0;
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
                _netProfit = 0;
                await displayDateRange(context);
                // queryValues();
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
                  _totalOriginalPrice.toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ListTile(
                title: Text('سعر الجملة', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  _totalWholesalePrice.toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ListTile(
                title: Text('التحصيل', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  _totalSellingPrice.toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ListTile(
                title: Text('ربح التاجر', style: _navigationBottomBartextStyle),
                subtitle: Text(
                  _totalTraderProfit.toString() + ' ₪',
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
                  _totalMarketerProfit.toString() + ' ₪',
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
              return _drawScreen(context, snapshot.data);
            }

            break;
        }
        return null;
      },
    );
  }

  Widget _drawScreen(BuildContext context, QuerySnapshot data) {
    numOfOperation = 0;
    _totalOriginalPrice = 0;
    _totalWholesalePrice = 0;
    _totalSellingPrice = 0;
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: data.documents.length,
        itemBuilder: (BuildContext context, int position) {
          Timestamp timeStamp = data.documents[position]['history'];
          List orderItem = data.documents[position]['order_item'];
          if (data.documents[position]['orderReceived']) {
            _netProfit = _calcNetProfit(orderItem);
          }
          numOfOperation = data.documents.length;
          data.documents.forEach((element) {
            List listOrderItems = element.data['order_item'];
            for (var order in listOrderItems) {
              _totalOriginalPrice += order['originalPrice'];
              _totalWholesalePrice += order['wholesalePrice'];
              _totalSellingPrice += order['sellingPrice'];

              // _totalTraderProfit += order['sellingPrice'];
            }
          });
          // print('oreder item is ' + orderItem[0]['deliveryPrice'].toString());
          DateTime dateTime = timeStamp.toDate();
          return Column(
            children: <Widget>[
              position == 0 ? _rowOfItemOrder(context, position) : Container(),
              InkWell(
                onTap: () {
                  _showMaterialDialog(
                      context, data, position, orderItem, dateTime);
                },
                child: Card(
                  color: data.documents[position]['orderReceived']
                      ? Colors.white
                      : Colors.red.shade100,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '(' + orderItem.length.toString() + ')',
                            softWrap: true,
                            style: TextStyle(
                              color: data.documents[position]['orderReceived']
                                  ? _grayColor
                                  : _blackColor,
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
                                color: data.documents[position]['orderReceived']
                                    ? _grayColor
                                    : _blackColor,
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
                              color: data.documents[position]['orderReceived']
                                  ? _grayColor
                                  : _blackColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          RichText(
                              textAlign: TextAlign.center,
                              softWrap: true,
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: (data.documents[position]
                                            ['orderReceived'])
                                        ? _netProfit.toString()
                                        : _calcDeliveryPricesIfOrderNotReceived(
                                                orderItem)
                                            .toString(),
                                    style: TextStyle(
                                      color: Color(0xFF1367B8),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    )),
                                TextSpan(
                                  text: '\t₪',
                                  style: TextStyle(
                                    color: data.documents[position]
                                            ['orderReceived']
                                        ? _grayColor
                                        : _blackColor,
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

  double _calcNetProfit(List orderItems) {
    double netProfit = 0;
    for (var orderItem in orderItems) {
      netProfit += orderItem['sellingPrice'] -
          (orderItem['wholesalePrice'] * orderItem['quantity']);
    }
    return netProfit;
  }

  double _calcOriginalPrice(List orderItems) {
    double netProfit = 0;
    for (var orderItem in orderItems) {
      netProfit += orderItem['sellingPrice'] -
          (orderItem['wholesalePrice'] * orderItem['quantity']);
    }
    return netProfit;
  }

  double _calcTraderProfit(List orderItems) {
    double traderProfit = 0;
    for (var orderItem in orderItems) {
      traderProfit += orderItem['quantity'] *
          (orderItem['wholesalePrice'] - orderItem['originalPrice']);
    }
    return traderProfit;
  }

  double _calcDeliveryPricesIfOrderNotReceived(List orderItems) {
    double deliveryPrices = 0;
    for (var orderItem in orderItems) {
      deliveryPrices += orderItem['deliveryPrice'];
    }
    return deliveryPrices;
  }

  double _calcTotalPriceFromFirebase(List orderItems, String field) {
    double value = 0;
    for (var orderItem in orderItems) {
      value += orderItem['$field'];
    }
    return value;
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

/**
 *  void queryValues() {
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
 */

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
      height: 50,
      // width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('العدد', style: _textStyleRow),
          Text('اسم الزبون', style: _textStyleRow),
          Text('التاريخ', style: _textStyleRow),
          Text('ربح المسوّق', style: _textStyleRow),
        ],
      ),
    );
  }

  _showMaterialDialog(BuildContext context, QuerySnapshot data, int position,
      List orderItems, DateTime dateTime) {
    String date = DateFormat('yyyy-MM-dd').format(dateTime).toString();
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
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dataTable(orderItems, data, position),
                divider(context),
                totalOfAll(
                    'إجمالي السعر الأصلي:',
                    _calcTotalPriceFromFirebase(orderItems, 'originalPrice')
                        .toString()),
                totalOfAll(
                    'إجمالي سعر الجملة:',
                    _calcTotalPriceFromFirebase(orderItems, 'wholesalePrice')
                        .toString()),
                totalOfAll(
                    'إجمالي التحصيل:',
                    _calcTotalPriceFromFirebase(orderItems, 'sellingPrice')
                        .toString()),
                totalOfAll(
                    'إجمالي التوصيل:',
                    _calcTotalPriceFromFirebase(orderItems, 'deliveryPrice')
                        .toString()),
                totalOfAll(
                    'إجمالي ربح التاجر:',
                    data.documents[position]['orderReceived']
                        ? _calcTraderProfit(orderItems).toString()
                        : '0'),
                totalOfAll(
                    'إجمالي ربح المسوّق:',
                    data.documents[position]['orderReceived']
                        ? _calcNetProfit(orderItems).toString()
                        : _calcDeliveryPricesIfOrderNotReceived(orderItems)
                            .toString()),
                dateOfTotal('تاريخ الفاتورة:', date),
                SizedBox(height: 20),
                divider(context),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: Text('تعديل')),
                    TextButton(onPressed: () {}, child: Text('حذف')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container divider(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 50),
      color: Colors.grey[300],
      height: 1,
      width: MediaQuery.of(context).size.width,
    );
  }

  RichText totalOfAll(String title, String value) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: title,
          style: GoogleFonts.cairo(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        TextSpan(
          text: "\t$value\t₪",
          style: GoogleFonts.cairo(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1367B8)),
        ),
      ]),
    );
  }

  RichText dateOfTotal(String title, String value) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: title,
          style: GoogleFonts.cairo(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        TextSpan(
          text: "\t$value",
          style: GoogleFonts.cairo(
              textStyle: Theme.of(context).textTheme.display1,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1367B8)),
        ),
      ]),
    );
  }

  DataTable dataTable(List orderItems, QuerySnapshot data, int position) {
    return DataTable(
      horizontalMargin: 7,
      columnSpacing: 15,
      columns: [
        DataColumn(
            label: _drawColumnTableProducts('الصنف'),
            numeric: false,
            tooltip: 'أسم الصنف'),
        DataColumn(
            label: _drawColumnTableProducts('الكمية'),
            numeric: true,
            tooltip: 'كمية الصنف المطلوبة'),
        DataColumn(
            label: _drawColumnTableProducts('السعر الأصلي'),
            numeric: true,
            tooltip: 'سعر الصنف الواحد الخاص بالتاجر'),
        DataColumn(
          label: _drawColumnTableProducts('سعر الجملة'),
          numeric: true,
          tooltip: 'سعر الجملة الخاص بالمسوّق',
        ),
        DataColumn(
          label: _drawColumnTableProducts('التحصيل'),
          numeric: true,
          tooltip: 'مجموع التحصيل من هذا الصنف',
        ),
        DataColumn(
          label: _drawColumnTableProducts('ربح التاجر'),
          numeric: true,
          tooltip: 'ربح التاجر من هذا الصنف',
        ),
        DataColumn(
          label: _drawColumnTableProducts('ربح المسوّق'),
          numeric: true,
          tooltip: 'ربح المسوّق من هذا الصنف',
        ),
        DataColumn(
          label: _drawColumnTableProducts('التوصيل'),
          numeric: true,
          tooltip: 'سعر التوصيل',
        ),
        DataColumn(
          label: _drawColumnTableProducts('تقرير'),
          numeric: false,
          tooltip: 'هل استلم أم لا',
        ),
      ],
      rows: orderItems
          .map((orderItem) => DataRow(cells: [
                DataCell(Text(orderItem['productName'].toString())),
                DataCell(Text(orderItem['quantity'].toString())),
                DataCell(Text(orderItem['originalPrice'].toString())),
                DataCell(Text(orderItem['wholesalePrice'].toString())),
                DataCell(Text(orderItem['sellingPrice'].toString())),
                DataCell(Text(data.documents[position]['orderReceived']
                    ? (orderItem['quantity'] *
                            _subTwoNum(orderItem['wholesalePrice'],
                                orderItem['originalPrice']))
                        .toString()
                    : '0')),
                DataCell(Text(data.documents[position]['orderReceived']
                    ? _subTwoNum(orderItem['sellingPrice'],
                            orderItem['quantity'] * orderItem['wholesalePrice'])
                        .toString()
                    : _calcDeliveryPricesIfOrderNotReceived(orderItems)
                        .toString())),
                DataCell(Text(orderItem['deliveryPrice'].toString())),
                DataCell(Text(data.documents[position]['comments'])),
              ]))
          .toList(),
    );
  }

  double _subTwoNum(double num1, double num2) {
    return num1 - num2;
  }

  Widget _drawColumnTableProducts(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
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
