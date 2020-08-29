import 'package:flutter/material.dart';
import 'package:animated_button/animated_button.dart';
import 'package:marketers_reports/auth/login.dart';

class HomeLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/back1.png'), fit: BoxFit.fill)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: height * .15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 35,
                  ),
                  Text(
                    'مرحباً بالجميع!',
                    style: TextStyle(
                        fontSize: 45,
                        fontFamily: 'font1',
                        color: Color(0xFFFE7550)),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 35,
                  ),
                  Text(
                    'من الجيّد رؤيتك مجدداً!',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 35,
                  ),
                  AnimatedButton(
                      enabled: true,
                      height: 50,
                      width: 130,
                      color: Color(0xFFFE7550),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        'دخول',
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w800),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}