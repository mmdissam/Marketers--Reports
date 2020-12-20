import 'package:animated_button/animated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/reports/home_screen.dart';
import 'package:marketers_reports/reports/new_report.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var _key = GlobalKey<FormState>();
  bool _autoValidation = false;
  bool _isError = false;
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _scaffold(context, height, width),
    );
  }

  Widget _scaffold(BuildContext context, double height, double width) {
    return Scaffold(
      body:  _isLoading ? _loading(context) : _form(context, height, width),
    );
  }

  Widget _form(BuildContext context, double height, double width) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/back2.png'))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              autovalidate: _autoValidation,
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: height * .3),
                  Text(
                    'السلام عليكم',
                    style: TextStyle(
                      color: Colors.black.withOpacity(.7),
                      fontSize: 45,
                    ),
                  ),
                  Container(
                    height: 8,
                    width: width * .5,
                    decoration: BoxDecoration(
                        color: Color(0xFFFE7550),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  _emailField(context),
                  _passwordField(context),
                  SizedBox(height: 25),
                  _loginButton(context, width),
                  SizedBox(height: 10),
                  _isError ? _errorMessage(context) : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 10),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'البريد الالكتروني',
            filled: true,
            fillColor: Colors.black12,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent))),
        style: TextStyle(
            color: Colors.black.withOpacity(.6),
            fontWeight: FontWeight.w600,
            fontSize: 16),
        validator: (value) {
          if (value.isEmpty) {
            return 'الرجاء إدخال الإيميل';
          }
          return null;
        },
      ),
    );
  }

  Widget _passwordField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscureText,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
            hintText: 'كلمة السر',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.remove_red_eye,
                color: Colors.grey,
              ),
            ),
            filled: true,
            fillColor: Colors.black12,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent))),
        style: TextStyle(
            color: Colors.black.withOpacity(.6),
            fontWeight: FontWeight.w600,
            fontSize: 16),
        validator: (value) {
          if (value.isEmpty) {
            return 'الرجاء إدخال كلمة السر';
          }
          return null;
        },
      ),
    );
  }

  Widget _loginButton(BuildContext context, double width) {
    return AnimatedButton(
        enabled: true,
        height: 50,
        width: width - 40,
        color: Color(0xFFFE7550),
        onPressed: _onLoginClicked,
        child: Text(
          'Login',
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),
        ));
  }

  void _onLoginClicked() async {
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
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim())
        .catchError((onError) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }).then((result) {
      if (result.user.uid == '1ClqQn53gYZCXvQaZI3eahQDY9E2') {
        Navigator.of(context)
            .pushReplacement(
            MaterialPageRoute(builder: (context) => NewReport()))
            .catchError((error) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        Navigator.of(context)
            .pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()))
            .catchError((error) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  Widget _loading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _errorMessage(BuildContext context) {
    return Center(
      child: Text(
        'الإيميل أو الهاتف غير صحيح',
        style: TextStyle(fontSize: 12, color: Colors.red,decoration: TextDecoration.underline,),
      ),
    );
  }
}
