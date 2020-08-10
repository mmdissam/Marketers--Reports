import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/reports/home_screen.dart';

import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  var _key = GlobalKey<FormState>();
  bool _autoValidation = false;
  bool _isLoading = false;
  String _error;

//  String test = 'Name is required';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
//        setState(() {
//          test = null;
//        });
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REGISTER'),
        centerTitle: true,
      ),
      body: _isLoading ? _loading(context) : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(36),
        child: Form(
          autovalidate: _autoValidation,
          key: _key,
          child: Column(
            children: <Widget>[
              _nameField(context),
              SizedBox(height: 20),
              _phoneField(context),
              SizedBox(height: 20),
              _emailField(context),
              SizedBox(height: 20),
              _passwordField(context),
              SizedBox(height: 20),
              _confirmPasswordField(context),
              SizedBox(height: 20),
              _registerButton(context),
              SizedBox(height: 20),
              _errorMessage(context),
              _rowHaveAccount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nameField(BuildContext context) {
    return TextFormField(
        controller: _nameController,
        decoration: InputDecoration(hintText: 'Your Name'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Name is required';
          }
          return null;
        });
  }

  Widget _emailField(BuildContext context) {
    return TextFormField(
        controller: _emailController,
        decoration: InputDecoration(hintText: 'Your Email'),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value.isEmpty) {
            return 'Email is required';
          }
          return null;
        });
  }

  Widget _passwordField(BuildContext context) {
    return TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(hintText: 'Password'),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        validator: (value) {
          if (value.isEmpty) {
            return 'Password is required';
          }
          return null;
        });
  }

  Widget _confirmPasswordField(BuildContext context) {
    return TextFormField(
        controller: _confirmPasswordController,
        decoration: InputDecoration(hintText: 'Confirm Password'),
        obscureText: true,
        validator: (value) {
          if (value.isEmpty) {
            return 'Confirm password is required';
          }
          return null;
        });
  }

  Widget _phoneField(BuildContext context) {
    return TextFormField(
        controller: _phoneController,
        decoration: InputDecoration(hintText: 'Your Phone'),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return 'Phone is required';
          }
          return null;
        });
  }

  Widget _registerButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        onPressed: _onRegisterClicked,
        child: Text('Register'),
      ),
    );
  }

  Widget _rowHaveAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Have an account?'),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: Text('Login'),
        ),
      ],
    );
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _errorMessage(BuildContext context) {
    if (_error == null) {
      return Container();
    }
    return Text(
      _error,
      style: TextStyle(color: Colors.red),
    );
  }

  void _onRegisterClicked() async {
    if (!_key.currentState.validate()) {
      setState(() {
        _autoValidation = true;
      });
    } else {
      setState(() {
        _autoValidation = false;
        _isLoading = true;
      });
    }

    //TODO:Connect with firebase
    registerUserInFirebase();
  }
  void registerUserInFirebase(){
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim())
        .then((authResult) {
      Firestore.instance.collection('profiles').document().setData({
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'user_id': authResult.user.uid,
      });
      Navigator.of(context)
          .pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()))
          .catchError((error) {
        setState(() {
          _isLoading = false;
          _error = "User registration error";
        });
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _error = "User registration error";
      });
    });
  }
}
