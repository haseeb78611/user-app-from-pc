import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khuwari_user_app/screens/my_home_page_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(),));
    },);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.blueGrey
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          )
      ),
      child: Text('User App', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w500),),
    );
  }
}
