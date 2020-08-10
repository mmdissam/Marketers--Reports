import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/auth/register.dart';

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

  double _price = 1;
  double _quantity = 1;
  double _deliveryPrice = 0;
  double _sellingPrice = 0;
  double _total = 0.0;
  double _netProfit = 0.0;
  var _selectedUser;

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
        title: Text('ADD REPORT'),
        centerTitle: true,
        actions: <Widget>[],
      ),
      drawer: _drawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddReport,
        child: Icon(Icons.add),
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Form(
          autovalidate: _autoValidation,
          key: _key,
          child: Column(
            children: <Widget>[
              _dropDownButton(context),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _showTotal(context),
                  SizedBox(width: 5),
                  _showNetProfit(context),
                ],
              ),
              ],
          ),
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

  Widget _drawer(context) {
    return Drawer(
      child: Center(
        child: ListTile(
            title: Text('REGISTER'),
            trailing: Icon(Icons.add_box),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RegisterScreen()));
            }),
      ),
    );
  }
  Widget _historyField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _historyController,
            decoration: InputDecoration(hintText: 'History'),
            keyboardType: TextInputType.datetime,
            validator: (value) {
              if (value.isEmpty) {
                return 'History is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _clientNameField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _clientNameController,
            decoration: InputDecoration(hintText: 'Client Name'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Client Name is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _phoneField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(hintText: 'Phone'),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value.isEmpty) {
                return 'Phone is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _productNameField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _productNameController,
            decoration: InputDecoration(hintText: 'Product Name'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Product Name is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _quantityField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(hintText: 'Quantity'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _quantity = double.tryParse(value);
              setState(() {
                _totalController.text =
                    (_quantity * _price + _deliveryPrice).toString();
                _netProfitController.text = (_sellingPrice - _total).toString();
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Quantity is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _priceField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _priceController,
            decoration: InputDecoration(hintText: 'Price'),
            onChanged: (value) {
              _price = double.tryParse(value);
              setState(() {
                _totalController.text =
                    (_quantity * _price + _deliveryPrice).toString();
                _netProfitController.text = (_sellingPrice - _total).toString();
              });
            },
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return 'Price is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _deliveryPriceField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _deliveryPriceController,
            decoration: InputDecoration(hintText: 'Delivery Price'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _deliveryPrice = double.tryParse(value);
              setState(() {
                _totalController.text =
                    (_quantity * _price + _deliveryPrice).toString();
                _netProfitController.text = (_sellingPrice - _total).toString();
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Delivery Price is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _sellingPriceField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _sellingPriceController,
            decoration: InputDecoration(hintText: 'Selling Price'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _sellingPrice = double.tryParse(value);
              setState(() {
                _total = (_quantity * _price + _deliveryPrice);
                _netProfit = (_sellingPrice - _total);
              });
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Selling price is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _commentsField(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
            controller: _commentsController,
            decoration: InputDecoration(hintText: 'Comments'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Comments is required';
              }
              return null;
            }),
      ),
    );
  }

  Widget _showTotal(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Text('$_total'),
        ),
      ),
    );
  }

  Widget _showNetProfit(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Text('$_netProfit'),
        ),
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
                  hint: Text(
                      'Choose user'
                  ),
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
  void _storeDataInFirebase() {
    FirebaseAuth.instance.currentUser().then((user) {
      Firestore.instance.collection('reports').document().setData({
        'user_id': _selectedUser,
        'history': _historyController.text.trim(),
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

/*
* Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                Card(
                  child: Container(
                    width: MediaQuery.of(context).size.width *0.4,
                    height: 40,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text('Total:$_total'),
                    ),
                  ),
                ),
                  Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width *0.4,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left:8.0),
                        child: Text('Net Profit:$_netProfit'),
                      ),
                    ),
                  ),
              ],),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                      controller: _commentsController,
                      decoration: InputDecoration(hintText: 'Comments'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Comments is required';
                        }
                        return null;
                      }),
                ),
              ),
*/
