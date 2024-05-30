import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/provider/auth_provider.dart'    as app_provider;
import 'package:app/homeScreen.dart';
import 'package:app/homeRemoScreen.dart';
import 'package:app/login/phoneAuthScreen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late app_provider.AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    checkSignIn();
  }

  Future<void> checkSignIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isSignedIn = prefs.getBool("is_signedin") ?? false;

  if (isSignedIn) {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    try {
      final String? carType = userDoc.get('carType');
      if (carType != null) {
        // المستخدم هو مصلح
        Navigator.pushReplacementNamed(context, HomeRemoScreen.id);
      } else {
        // المستخدم عادي
        Navigator.pushReplacementNamed(context, HomeScreen.id);
      }
    } catch (e) {
      // في حالة حدوث استثناء، يتم اعتبار المستخدم عاديًا
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    }
  } else {
    // المستخدم غير مسجل الدخول
    print('User not logged in');
  }
} else {
  Navigator.pushReplacementNamed(context, PhoneAuthScreen.id);
}
}
  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<app_provider.AuthProvider>(context, listen: false);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 0, 183, 255),
        height: size.height,
        width: double.infinity,
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: size.width * 0.3,
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Powered By Atil Nour El Houda",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
