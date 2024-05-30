import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart' as app_provider;

class PhoneAuthScreen extends StatefulWidget {
  static const id = 'phoneAuthScreen';

  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<app_provider.AuthProvider>(context, listen: false)
        .setPhoneTextController(_phoneTextController);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول'),
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        height: size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'assets/images/logoo.png',
              width: size.width / 2,
            ),
            Text(
              'رقم الهاتف',
              style: TextStyle(fontSize: 22, color: Colors.blue),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ادخل رقم هاتفك',
                  prefix: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('+213'),
                  ),
                ),
                maxLength: 9,
                controller: _phoneTextController,
                keyboardType: TextInputType.phone,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Provider.of<app_provider.AuthProvider>(context, listen: false)
                    .signInWithPhone(
                        context, "+213${_phoneTextController.text.trim()}");
              },
              child: Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}
