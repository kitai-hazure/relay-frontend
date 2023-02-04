import 'package:flutter/material.dart';
import 'package:relay/screens/home_screen.dart';
import 'package:relay/screens/onboarding.dart';
import 'package:relay/screens/sign_in_screen.dart';
//import 'package:programmerprofile/home/view/temp_home2.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String routeName = "/splashScreen";
  @override
  Splash createState() => Splash();
}

class Splash extends State<SplashScreen> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);
    print("SEEEEEN"+seen.toString());

    if (seen) {
      _handleStartScreen();
      if (!mounted) return;
      // Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignInScreen()));
    } else {
      await prefs.setBool('seen', true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> OnboardingPage()));
    }
  }
   @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            color: const Color.fromARGB(255, 4, 24, 40),
            child: const Text("SPLASH SCREEN", style: TextStyle(color: Colors.white))),
      ),
    );
  }


  Future<void> _handleStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == null) {
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignInScreen()));
    } else {
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
       prefs.setBool("isLoggedIn", true);
    }
  }
}