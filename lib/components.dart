/*import 'package:flutter/material.dart';
import 'appBrain.dart';
import 'package:app/firebaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';





class RoundIconButton extends StatelessWidget {
  RoundIconButton(
      {required this.icon,
        required this.onPressed,
        this.iconColor,
        this.buttonColor});
  final IconData icon;
  final Function onPressed;
  final iconColor;
  final buttonColor;
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(
        icon,
        color: iconColor,
      ),
      onPressed: () { // استخدم هنا دالة معينة تقوم بتنفيذ الإجراء المطلوب عند الضغط
  // تنفيذ الإجراء المطلوب
      },
      elevation: 0.0,
      constraints: BoxConstraints.tightFor(
        width: 56.0,
        height: 56.0,
      ),
      shape: CircleBorder(),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      fillColor: buttonColor,
    );
  }
}

 
class RoundedPinTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          6,
          (index) => SizedBox(
            width: 50,
            height: 70,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(fontSize: 25.0, color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                counterText: "",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              onChanged: (value) {
                // Perform any validation or processing here
                if (value.length == 1) {
                  // Move to the next field if a value is entered
                  FocusScope.of(context).nextFocus();
                } else if (value.isEmpty) {
                  // Move to the previous field if value is deleted
                  FocusScope.of(context).previousFocus();
                }
              },
              onSubmitted: (pin) async {
                // Verify OTP using Firebase service
                await FirebaseService().verifyOTP(context, pin);
              },
            ),
          ),
        ),
      ),
    );
  }
}*/