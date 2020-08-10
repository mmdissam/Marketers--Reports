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

  Widget _scaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN'),
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
              _emailField(context),
              SizedBox(height: 20),
              _passwordField(context),
              SizedBox(height: 20),
              _loginButton(context),
              SizedBox(height: 20),
              _isError ? _errorMessage(context) : Container(),
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

  Widget _errorMessage(BuildContext context) {
    return Center(
      child: Text(
        'Email or Password is wrong',
        style: TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
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
    //TODO:Connect with firebase
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .catchError((onError) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _passwordController = TextEditingController(text: '');
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
        decoration: InputDecoration(
          hintText: 'Password',
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
        ),
        obscureText: _obscureText,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value.isEmpty) {
            return 'Password is required';
          }
          return null;
        });
  }

  Widget _loginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        onPressed: _onLoginClicked,
        child: Text('Login'),
      ),
    );
  }
}
