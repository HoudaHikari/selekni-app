/*import 'package:app/login/auth_service.dart';
import 'package:app/login/otpScreen.dart';
import 'package:flutter/material.dart';
import 'package:app/firebaseService2.dart';
import 'package:app/login/phoneAuthScreen.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'loginscreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseService firebaseService = FirebaseService();

  final _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          height: size.height,
          width: double.infinity,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: size.width / 2,
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  const Text(
                    'login',
                    style: TextStyle(
                        fontSize: 22, color: Color.fromARGB(255, 0, 81, 148)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        firebaseService.googleSignIn(
                            context, ""); // استخدام قيمة فارغة هنا
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Text(
                        'login with google',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/