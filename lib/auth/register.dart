import 'package:animated_button/animated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketers_reports/reports/admin_home.dart';
import 'package:marketers_reports/shared_ui/nav_menu.dart';

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
  bool _obscureText = true;
  OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.transparent));

  String _required = 'مطلوب**';

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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
      child: _scaffold(context, height, width),
    );
  }

  Widget _scaffold(BuildContext context, double height, double width) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'حساب جديد',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      drawer: drawer(context),
      body: _isLoading ? _loading(context) : _form(context, height, width),
    );
  }

  Widget _form(BuildContext context, double height, double width) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/back3.png'),
                fit: BoxFit.cover),
            color: Colors.white),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            autovalidate: _autoValidation,
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 120),
                _nameField(context),
                SizedBox(height: 20),
                _phoneField(context),
                SizedBox(height: 20),
                _emailField(context),
                SizedBox(height: 20),
                _passwordField(context),
                SizedBox(height: 20),
                _confirmPasswordField(context),
                SizedBox(height: 40),
                _registerButton(context, width),
                SizedBox(height: 20),
                _errorMessage(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameField(BuildContext context) {
    return TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
            hintText: 'اسم المسوّق',
            filled: true,
            fillColor: Colors.black12,
            focusedBorder: _outlineInputBorder,
            border: _outlineInputBorder,
            disabledBorder: _outlineInputBorder,
            enabledBorder: _outlineInputBorder),
        style: TextStyle(
            color: Colors.black.withOpacity(.6),
            fontWeight: FontWeight.w600,
            fontSize: 16),
        validator: (value) {
          if (value.isEmpty) {
            return _required;
          }
          return null;
        });
  }

  Widget _emailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'الإيميل',
        filled: true,
        fillColor: Colors.black12,
        focusedBorder: _outlineInputBorder,
        border: _outlineInputBorder,
        disabledBorder: _outlineInputBorder,
        enabledBorder: _outlineInputBorder,
      ),
      style: TextStyle(
          color: Colors.black.withOpacity(.6),
          fontWeight: FontWeight.w600,
          fontSize: 16),
      validator: validateEmail,
    );
  }

  Widget _passwordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      validator: validatePassword,
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
          focusedBorder: _outlineInputBorder,
          border: _outlineInputBorder,
          disabledBorder: _outlineInputBorder,
          enabledBorder: _outlineInputBorder),
      style: TextStyle(
          color: Colors.black.withOpacity(.6),
          fontWeight: FontWeight.w600,
          fontSize: 16),
    );
  }

  Widget _confirmPasswordField(BuildContext context) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
          hintText: 'تأكيد كلمة السر',
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
          focusedBorder: _outlineInputBorder,
          border: _outlineInputBorder,
          disabledBorder: _outlineInputBorder,
          enabledBorder: _outlineInputBorder),
      style: TextStyle(
          color: Colors.black.withOpacity(.6),
          fontWeight: FontWeight.w600,
          fontSize: 16),
      validator: (confirmation) {
        return confirmation.isEmpty
            ? _required
            : validationEqual(confirmation, _passwordController.text)
                ? null
                : 'كلمة المرور غير متطابقة';
      },
    );
  }

  Widget _phoneField(BuildContext context) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          hintText: 'الهاتف',
          filled: true,
          fillColor: Colors.black12,
          focusedBorder: _outlineInputBorder,
          border: _outlineInputBorder,
          disabledBorder: _outlineInputBorder,
          enabledBorder: _outlineInputBorder),
      style: TextStyle(
          color: Colors.black.withOpacity(.6),
          fontWeight: FontWeight.w600,
          fontSize: 16),
      validator: validatePhone,
    );
  }

  Widget _registerButton(BuildContext context, double width) {
    return AnimatedButton(
        enabled: true,
        height: 50,
        width: width - 40,
        color: Color(0xFFFE7550),
        onPressed: _onRegisterClicked,
        child: Text(
          'تسجيل',
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.w800),
        ));
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
      _key.currentState.save();
      setState(() {
        _autoValidation = false;
        _isLoading = true;
      });
      //connect with firebase
      registerUserInFirebase();
    }
  }

  void registerUserInFirebase() {
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
          .pushReplacement(MaterialPageRoute(builder: (context) => AdminHome()))
          .catchError((error) {
        setState(() {
          _isLoading = false;
          _error = "هناك خطأ في التسجيل";
        });
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _error = "هناك خطأ في التسجيل";
      });
    });
  }

  String validatePhone(String value) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.replaceAll(" ", "").isEmpty) {
      return _required;
    } else if (value.replaceAll(" ", "").length != 10) {
      return 'يجيب أن يكون الهاتف أطول من 10 أرقام';
    } else if (!regExp.hasMatch(value.replaceAll(" ", ""))) {
      return 'يجب أن يكون رقم الهاتف من أرقام فقط';
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return _required;
    } else if (!regExp.hasMatch(value)) {
      return 'الإيميل غير صحيح';
    } else {
      return null;
    }
  }

  String validatePassword(String value) {
    if (value.isEmpty) {
      return _required;
    } else if (value.length < 4) {
      return 'كلمة الرور أقل من 4 أحرف';
    }
    return null;
  }

  String validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return _required;
    } else if (value.length < 4) {
      return 'كلمة الرور أقل من 4 أحرف';
    }
    return null;
  }

  bool validationEqual(String currentValue, String checkValue) {
    if (currentValue == checkValue) {
      return true;
    } else {
      return false;
    }
  }
}
