import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketers_reports/shared_ui/nav_menu.dart';

class NewReport extends StatefulWidget {
  @override
  _NewReportState createState() => _NewReportState();
}

class _NewReportState extends State<NewReport> {
  TextEditingController _historyController = TextEditingController();
  TextEditingController _clientNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _deliveryPriceController = TextEditingController();
  TextEditingController _totalController = TextEditingController();
  TextEditingController _netProfitController = TextEditingController();
  TextEditingController _sellingPriceController = TextEditingController();
  TextEditingController _commentsController = TextEditingController();

  var _key = GlobalKey<FormState>();
  bool _autoValidation = false;
  bool _isLoading = false;
  bool _isError = false;
  String _required ='مطلوب**';

  double _price = 1;
  double _quantity = 1;
  double _deliveryPrice = 0;
  double _sellingPrice = 0;
  double _total = 0.0;
  double _netProfit = 0.0;
  var _selectedUser;
  Timestamp _dateTimeStamp = Timestamp.fromDate(DateTime.now());

  @override
  void dispose() {
    _historyController.dispose();
    _clientNameController.dispose();
    _phoneController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _deliveryPriceController.dispose();
    _totalController.dispose();
    _netProfitController.dispose();
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
        title: Text('إضافة تقرير'),
        centerTitle: true,
        actions: <Widget>[],
      ),
      drawer: drawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddReport,
        child: Icon(Icons.save),
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            _dropDownButton(context),
            Form(
              autovalidate: _autoValidation,
              key: _key,
              child: Column(
                children: <Widget>[
                  _historyField(context),
                  SizedBox(height: 20),
                  _clientNameField(context),
                  SizedBox(height: 20),
                  _phoneField(context),
                  SizedBox(height: 20),
                  _productNameField(context),
                  SizedBox(height: 20),
                  _quantityField(context),
                  SizedBox(height: 20),
                  _priceField(context),
                  SizedBox(height: 20),
                  _deliveryPriceField(context),
                  SizedBox(height: 20),
                  _sellingPriceField(context),
                  SizedBox(height: 20),
                  _commentsField(context),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _showTotal(context),
                      SizedBox(width: 5),
                      _showNetProfit(context),
                    ],
                  ),
                  SizedBox(height: 20),
                  _isError
                      ? _errorMessage(context, 'الرجاء إدخال اسم المسوّق')
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(hintText: 'الكمية'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _quantity = double.tryParse(value);
              setState(() {
                _totalController.text = (_quantity * _price).toString();
                _netProfitController.text = (_sellingPrice - _total).toString();
              });
            },
            validator: validatePrices),
      ),
    );
  }

  Widget _priceField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _priceController,
            decoration: InputDecoration(hintText: 'السعر'),
            onChanged: (value) {
              _price = double.tryParse(value);
              setState(() {
                _totalController.text = (_quantity * _price).toString();
                _netProfitController.text = (_sellingPrice - _total).toString();
              });
            },
            keyboardType: TextInputType.number,
            validator: validatePrices
        ),
      ),
    );
  }

  Widget _deliveryPriceField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _deliveryPriceController,
            decoration: InputDecoration(hintText: 'التوصيل'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _deliveryPrice = double.tryParse(value);
              setState(() {
                _totalController.text = (_quantity * _price).toString();
                _netProfitController.text = (_sellingPrice - _total).toString();
              });
            },
            validator: validatePrices,
        ),
      ),
    );
  }

  Widget _sellingPriceField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _sellingPriceController,
            decoration: InputDecoration(hintText: 'التحصيل'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _sellingPrice = double.tryParse(value);
              setState(() {
                _total = (_quantity * _price);
                _netProfit = (_sellingPrice - _total);
              });
            },
            validator: validatePrices,),
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

  Widget _showTotal(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text('السعر الكلّي بالجملة',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Card(
            color: Colors.red.shade300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:55, vertical: 15),
              child: Text(_total.toString()),
            ),
          )
        ],
      ),
    );
  }

  Widget _showNetProfit(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text('ربح المسوّق',style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Card(
            color: Colors.green.shade300,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
              child: Text(_netProfit.toString()),
            ),
          )
        ],
      ),
    );
  }

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
            return Container(
              width: double.infinity,
              child: Center(
                child: DropdownButton(
                  items: userItems,
                  onChanged: (userValue) {
                    setState(() {
                      _selectedUser = userValue;
                    });
//                    final snackBar =
//                    SnackBar(content: Text('Selected User is ${documentSnapshot.data['name']}'));
//                    Scaffold.of(context).showSnackBar(snackBar);
//
                  },
                  value: _selectedUser,
                  isExpanded: false,
                  hint: Text('اسم المسوّق'),
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
        style: TextStyle(color: Colors.red),
      ),
    );
  }
  String validatePhone(String value) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.trim().isEmpty) {
      return null;
    }
    else if (value.replaceAll(" ", "").length != 10) {
      return 'يجيب أن يكون الهاتف من 10 أرقام';
    } else if (!regExp.hasMatch(value.replaceAll(" ", ""))) {
      return 'يجب أن يكون رقم الهاتف من أرقام فقط';
    }
    return null;
  }
  String validateNames(String value) {
    String pattern = r'(^[أ-ي]+$)';
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
    } else {
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance.collection('reports').document().setData({
          'user_id': _selectedUser,
          'history': _dateTimeStamp,
          'clientName': _clientNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'productName': _productNameController.text.trim(),
          'quantity': _quantityController.text.trim(),
          'price': _priceController.text.trim(),
          'deliveryPrice': _deliveryPriceController.text.trim(),
          'total': _total,
          'netProfit': _netProfit,
          'sellingPrice': _sellingPrice,
          'comments': _commentsController.text.trim(),
        }).then((_) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NewReport())));
      });
    }
  }
}
