import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketers_reports/models/order_item.dart';
import 'package:marketers_reports/models/report.dart';
import 'package:marketers_reports/shared_ui/nav_menu.dart';

class NewReport extends StatefulWidget {
  @override
  _NewReportState createState() => _NewReportState();
}

class _NewReportState extends State<NewReport> {
  // TextEditingController _historyController = TextEditingController();
  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _originalPriceController = TextEditingController();
  TextEditingController _wholesalePriceController = TextEditingController();
  TextEditingController _deliveryPriceController = TextEditingController();
  // TextEditingController _totalController = TextEditingController();
  TextEditingController _sellingPriceController = TextEditingController();
  TextEditingController _commentsController = TextEditingController();

  var _key = GlobalKey<FormState>();
  var _keyShowDialog = GlobalKey<FormState>();
  bool _autoValidation = false;
  bool _isLoading = false;
  bool _isError = false;
  bool _isErrorCartIsNull = false;
  String _required = 'مطلوب**';
  // double _total = 0.0;
  // double _netProfit = 0.0;
  List<OrderItem> _listOrderItem = [];
  bool _orderReceived = false;
  var _selectedUser;
  Timestamp _dateTimeStamp = Timestamp.fromDate(DateTime.now());
  TextStyle _textStylePirce = TextStyle(color: Colors.black87);
  TextStyle _textStyle =
      TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

  @override
  void dispose() {
    // _historyController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _originalPriceController.dispose();
    _wholesalePriceController.dispose();
    _deliveryPriceController.dispose();
    // _totalController.dispose();
    _sellingPriceController.dispose();
    _commentsController.dispose();
    super.dispose();
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
      child: _scaffold(context),
    );
  }

  Widget _scaffold(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة تقرير',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _onAddReport,
            tooltip: 'حفظ الطلبية',
          )
        ],
      ),
      drawer: drawer(context),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _onAddReport,
      //   child: Icon(Icons.save),
      // ),
      body: _isLoading ? _loading(context) : _form(context),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: <Widget>[
            _dropDownButton(context),
            SizedBox(height: 20),
            _historyField(context),
            Form(
              autovalidate: _autoValidation,
              key: _key,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  _clientNameField(context),
                  SizedBox(height: 20),
                  _phoneField(context),
                  SizedBox(height: 20),
                  _commentsField(context),
                  SizedBox(height: 30),
                  _checkBox(context),
                  SizedBox(height: 30),
                  _addOrderButton(context),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     _showTotal(context),
                  //     SizedBox(width: 5),
                  //     _showNetProfit(context),
                  //   ],
                  // ),
                  SizedBox(height: 20),
                  _isError
                      ? _errorMessage(context, 'الرجاء إدخال اسم المسوّق')
                      : Container(),
                  _isErrorCartIsNull
                      ? _errorMessage(context, 'قائمة الطلبات فارغة')
                      : Container(),
                  Container(
                    color: Colors.black12,
                    child: _testRow(context),
                  ),
                  Container(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _testRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataTextStyle: TextStyle(color: Colors.blueAccent),
        horizontalMargin: 16,
        columnSpacing: 16,
        sortAscending: true,
        columns: [
          DataColumn(
              label: _drawColumnTableProducts('الصنف'),
              numeric: false,
              tooltip: 'إسم الصنف'),
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
            label: _drawColumnTableProducts('التوصيل'),
            numeric: true,
            tooltip: 'سعر التوصيل',
          ),
          DataColumn(
            label: _drawColumnTableProducts('التحصيل'),
            numeric: true,
            tooltip: 'مجموع التحصيل من هذا الصنف',
          ),
          // DataColumn(
          //   label: _drawColumnTableProducts('ربح المسوّق'),
          //   numeric: true,
          //   tooltip: 'ربح المسوّق من هذا الصنف',
          // ),
          DataColumn(
            label: _drawColumnTableProducts('تقرير'),
            numeric: false,
            tooltip: 'هل استلم أم لا',
          ),
        ],
        rows: _listOrderItem
            .map(
              (orderItem) => DataRow(
                // onSelectChanged: (_) {
                //   // print(orderItem.productName);
                //   // _onButtomPressedShowModelButtomSheet();
                // },
                cells: [
                  DataCell(
                    Text(
                      orderItem.productName.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    showEditIcon: true,
                    onTap: () {
                      print(orderItem.productName);
                      setState(() {
                        _onButtomPressedShowModelButtomSheet(orderItem);
                      });
                    },
                  ),
                  // DataCell(_dataCellText(orderItem.productName.toString())),
                  DataCell(_dataCellText(orderItem.quantity.toString())),
                  DataCell(_dataCellText(orderItem.originalPrice.toString())),
                  DataCell(_dataCellText(orderItem.wholesalePrice.toString())),
                  DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(orderItem.sellingPrice.toString())),
                  // DataCell(_dataCellText(orderItem.deliveryPrice.toString())),
                  DataCell(_dataCellText(_commentsController.text)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _drawColumnTableProducts(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _dataCellText(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 16,
      ),
    );
  }

  SingleChildScrollView bottomNavigationBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 700,
        color: Colors.deepOrange,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text('العدد', style: _textStyle),
                subtitle: Text(
                  _listOrderItem.length.toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('التحصيل', style: _textStyle),
                subtitle: Text(
                  calcSellingPrice().toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('السعر الأصلي', style: _textStyle),
                subtitle: Text(
                  calcOriginalPrice().toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('سعر الجملة', style: _textStyle),
                subtitle: Text(
                  calcWholesalePrice().toString() + ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('التوصيل', style: _textStyle),
                subtitle: Text(
                  _orderReceived
                      ? _calcDeliveryPricesIfOrderNotReceived().toString() +
                          ' ₪'
                      : (_calcDeliveryPricesIfOrderNotReceived() * -1)
                              .toString() +
                          ' ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('ربح التاجر', style: _textStyle),
                subtitle: Text(
                  _orderReceived ? _calcTraderProfit().toString() : '0.0 ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text('ربح المسوّق', style: _textStyle),
                subtitle: Text(
                  _orderReceived ? calcTotalNetProfit().toString() : '0.0 ₪',
                  style: _textStylePirce,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calcSellingPrice() {
    double totalSellingPrice = 0;
    for (var item in _listOrderItem) {
      totalSellingPrice += item.sellingPrice;
    }
    return totalSellingPrice;
  }

  double calcOriginalPrice() {
    double totalOriginalPrice = 0;
    for (var item in _listOrderItem) {
      totalOriginalPrice += (item.originalPrice * item.quantity);
    }
    return totalOriginalPrice;
  }

  double calcWholesalePrice() {
    double totalWholesalePrice = 0;
    for (var item in _listOrderItem) {
      totalWholesalePrice += (item.wholesalePrice * item.quantity);
    }
    return totalWholesalePrice;
  }

  double calcTotalNetProfit() {
    return calcSellingPrice() - calcWholesalePrice();
  }

  double calcNetProfit(int position) {
    return (_listOrderItem[position].sellingPrice -
        _listOrderItem[position].wholesalePrice);
  }

  double _calcTraderProfit() {
    double traderProfit = 0;
    for (var orderItem in _listOrderItem) {
      traderProfit += orderItem.quantity *
          (orderItem.wholesalePrice - orderItem.originalPrice);
    }
    return traderProfit;
  }

  double _calcDeliveryPricesIfOrderNotReceived() {
    double deliveryPrices = 0;
    for (var orderItem in _listOrderItem) {
      deliveryPrices += orderItem.deliveryPrice;
    }
    return deliveryPrices;
  }

  _checkBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          Text(
            'إستلم أم لا؟',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          SizedBox(width: 15),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            width: 24,
            height: 24,
            child: Checkbox(
              value: _orderReceived,
              tristate: false,
              onChanged: (bool isChecked) {
                setState(() {
                  _orderReceived = isChecked;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _addOrderButton(BuildContext context) {
    return RaisedButton(
      color: Color(0xFFFE7550),
      child: Text(
        'إضافة طلبية جديدة',
        style: TextStyle(
            fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      onPressed: () {
        _showMaterialDialog();
      },
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _onAddReport() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = true;
      });
    } else {
      setState(() {
        _autoValidation = false;
        _isLoading = true;
      });

      _storeDataInFirebase();
    }
  }

  Widget _historyField(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.date_range),
              ),
              SizedBox(width: 10),
              Text(DateFormat('yyyy-MM-dd').format(_dateTimeStamp.toDate())),
            ],
          ),
          FlatButton(
            child: Text(
              'تغيير',
              style: TextStyle(color: Colors.deepOrange),
            ),
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2015),
                lastDate: DateTime(2030),
              ).then((date) {
                setState(() {
                  _dateTimeStamp = Timestamp.fromDate(date);
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _clientNameField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: _clientNameController,
          decoration: InputDecoration(hintText: 'اسم الزبون'),
          validator: validateNames,
        ),
      ),
    );
  }

  Widget _phoneField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(hintText: 'الهاتف'),
          keyboardType: TextInputType.phone,
          validator: validatePhone,
        ),
      ),
    );
  }

  Widget _productNameField(BuildContext context) {
    return Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: _productNameController,
          decoration: InputDecoration(hintText: 'اسم الصنف'),
          validator: validateNames,
        ),
      ),
    );
  }

  Widget _quantityField(BuildContext context) {
    return Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(hintText: 'الكمية'),
            keyboardType: TextInputType.number,
            validator: validatePrices),
      ),
    );
  }

  Widget _originalPriceField(BuildContext context) {
    return Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _originalPriceController,
            decoration: InputDecoration(hintText: 'السعر الأصلي'),
            keyboardType: TextInputType.number,
            validator: validatePrices),
      ),
    );
  }

  Widget _wholesalePriceField(BuildContext context) {
    return Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _wholesalePriceController,
            decoration: InputDecoration(hintText: 'سعر الجملة'),
            keyboardType: TextInputType.number,
            validator: validatePrices),
      ),
    );
  }

  Widget _deliveryPriceField(BuildContext context) {
    return Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: _deliveryPriceController,
          decoration: InputDecoration(hintText: 'التوصيل'),
          keyboardType: TextInputType.number,
          validator: validatePrices,
        ),
      ),
    );
  }

  Widget _sellingPriceField(BuildContext context) {
    return Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: _sellingPriceController,
          decoration: InputDecoration(hintText: 'التحصيل'),
          keyboardType: TextInputType.number,
          validator: validatePrices,
        ),
      ),
    );
  }

  Widget _commentsField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: _commentsController,
          decoration: InputDecoration(hintText: 'تقرير'),
        ),
      ),
    );
  }

  // Widget _showTotal(BuildContext context) {
  //   return Container(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.only(right: 5),
  //           child: Text(
  //             'السعر الكلّي بالجملة',
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         Card(
  //           color: Colors.red.shade300,
  //           child: Container(
  //               width: MediaQuery.of(context).size.width * 0.4,
  //               height: 60,
  //               child: Center(
  //                 child: Text(_total.toString()),
  //               )),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _showNetProfit(BuildContext context) {
  //   return Container(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Padding(
  //           padding: const EdgeInsets.only(right: 5),
  //           child: Text(
  //             'ربح المسوّق',
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         Card(
  //           color: Colors.green.shade300,
  //           child: Container(
  //               width: MediaQuery.of(context).size.width * 0.4,
  //               height: 60,
  //               child: Center(child: Text(_netProfit.toString()))),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _dropDownButton(context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('profiles').snapshots(),
      builder: (context, snapshot) {
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
            List<DropdownMenuItem> userItems = [];
            DocumentSnapshot documentSnapshot;
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              documentSnapshot = snapshot.data.documents[i];
              userItems.add(
                DropdownMenuItem(
                  child: Text(documentSnapshot.data['name']),
                  value: '${documentSnapshot.data['user_id']}',
                ),
              );
            }
            return Card(
              color: Color(0xffFDDC9B),
              child: Center(
                child: DropdownButton(
                  items: userItems,
                  onChanged: (userValue) {
                    setState(() {
                      _selectedUser = userValue;
                    });
                    //                    final snackBar =
                    //                    SnackBar(content: Text('Selected User is ${documentSnapshot.data['name']}'));
                    //  Scaffold.of(context).showSnackBar(snackBar);
                    ////
                  },
                  value: _selectedUser,
                  isExpanded: false,
                  hint: Text('الرجاء اختيار اسم المسوّق'),
                ),
              ),
            );
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
        style:
            TextStyle(color: Colors.red, decoration: TextDecoration.underline),
      ),
    );
  }

  String validatePhone(String value) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.trim().isEmpty) {
      return null;
    } else if (value.replaceAll(" ", "").length != 10) {
      return 'يجب أن يكون رقم الهاتف مكوّن من 10 أرقام';
    } else if (!regExp.hasMatch(value.replaceAll(" ", ""))) {
      return 'يجب أن يحتوي رقم الهاتف على أرقام فقط';
    }
    return null;
  }

  String validateNames(String value) {
    String pattern = r"^[A-Za-z أ-ي]+$";
    RegExp regExp = new RegExp(pattern);
    if (value.trim().isEmpty) {
      return _required;
    } else if (!regExp.hasMatch(value.replaceAll(" ", ""))) {
      return 'يجب أن يكون الإسم من الأحرف فقط';
    }
    return null;
  }

  String validatePrices(String value) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.trim().isEmpty) {
      return _required;
    } else if (!regExp.hasMatch(value.trim())) {
      return 'يجب أن يكون من الأرقام فقط';
    }
    return null;
  }

  void _storeDataInFirebase() {
    if (_selectedUser == null) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
    if (_listOrderItem.length == 0) {
      setState(() {
        _isErrorCartIsNull = true;
        _isLoading = false;
      });
    } else {
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance.collection('reports').document().setData({
          'user_id': _selectedUser,
          'history': _dateTimeStamp,
          'clientName': _clientNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'orderReceived': _orderReceived,
          // 'total': _total,
          'comments': _commentsController.text.trim(),
          // 'netProfit': _netProfit,
          'order_item': Report.toJsonOrderItem(_listOrderItem),
        }).then((_) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NewReport())));
      });
    }
  }

  // Widget _showAddOrder(BuildContext context) {
  //   return IconButton(
  //     icon: Icon(Icons.shopping_cart),
  //     onPressed: () {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => Cart(listOrder: _listOrderItem)));
  //     },
  //   );
  // }

  _showMaterialDialog() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        backgroundColor: Colors.white,
        title: new Text("إضافة طلبية جديدة"),
        content: SingleChildScrollView(
          child: Form(
            key: _keyShowDialog,
            autovalidate: _autoValidation,
            child: Column(
              children: [
                _productNameField(context),
                SizedBox(height: 20),
                _quantityField(context),
                SizedBox(height: 20),
                _originalPriceField(context),
                SizedBox(height: 20),
                _wholesalePriceField(context),
                SizedBox(height: 20),
                _deliveryPriceField(context),
                SizedBox(height: 20),
                _sellingPriceField(context),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('إلغاء', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('حفظ', style: TextStyle(color: Colors.green)),
            onPressed: () {
              if (!_keyShowDialog.currentState.validate()) {
                setState(() {
                  _autoValidation = true;
                });
              } else {
                setState(() {
                  _autoValidation = false;
                });
                _addToCart();
                _keyShowDialog.currentState.reset();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    setState(
      () {
        _listOrderItem.add(
          OrderItem(
            _productNameController.text.trim(),
            double.parse(_quantityController.text.trim()),
            double.parse(_originalPriceController.text.trim()),
            double.parse(_wholesalePriceController.text.trim()),
            double.parse(_sellingPriceController.text.trim()),
            _orderReceived
                ? double.parse(_deliveryPriceController.text.trim())
                : double.parse(_deliveryPriceController.text.trim()) * -1,
          ),
        );
        // _total += (double.parse(_originalPriceController.text.trim()) *
        //     double.parse(_quantityController.text.trim()));

        // _netProfit +=
        //     (double.parse(_sellingPriceController.text.trim()) - _total);
      },
    );
  }

  void _onButtomPressedShowModelButtomSheet(OrderItem orderItem) {
    showModalBottomSheet(
      enableDrag: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              trailing: Icon(Icons.edit, size: 28, color: Colors.blue),
              title: Text('تعديل', style: TextStyle(fontSize: 25)),
              onTap: () {},
            ),
            ListTile(
              trailing: Icon(Icons.delete, size: 28, color: Colors.red),
              title: Text('حذف', style: TextStyle(fontSize: 25)),
              onTap: () {
                setState(() {
                  _listOrderItem.remove(orderItem);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
