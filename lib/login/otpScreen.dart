import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/login/userInfoScreen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  OTPScreen({Key? key, required this.verificationId, required this.phoneNumber})
      : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("التحقق من رقم الهاتف"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
                maxLength: 6,
              controller: otpController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "ادخل الرمز السري",
                suffixIcon: Icon(Icons.phone),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: otpController.text.toString(),
                );
                await FirebaseAuth.instance.signInWithCredential(credential);
                Navigator.pushReplacementNamed(
                  context,
                  UserInfoScreen.id,
                  arguments: widget.phoneNumber,
                );
              } catch (ex) {
                debugPrint(ex.toString());
              }
            },
            child: Text("تحقق"),
          ),
        ],
      ),
    );
  }
}
