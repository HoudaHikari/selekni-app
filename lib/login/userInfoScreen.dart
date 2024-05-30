import 'dart:io';
import 'package:app/homeScreen.dart';
import 'package:app/homeRemoScreen.dart';
import 'package:app/vehicleScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/utils/utils.dart';
import 'package:app/login/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart' as app_provider;

class UserInfoScreen extends StatefulWidget {
  static const id = 'userInfoScreen';

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final nameController = TextEditingController();
  final prenameController = TextEditingController();
  final emailController = TextEditingController();
  String? selectedWilaya;

  @override
  void dispose() {
    nameController.dispose();
    prenameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<app_provider.AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text('معلومات المستخدم'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  InkWell(
                    child: CircleAvatar(
                      backgroundColor: Colors.purple,
                      radius: 50,
                      child: Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: 'ادخل اسمك',
                            prefixIcon: Icon(Icons.account_circle),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: prenameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: 'ادخل لقبك',
                            prefixIcon: Icon(Icons.account_circle),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'ادخل بريدك الالكتروني',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: selectedWilaya,
                          onChanged: (newValue) {
                            setState(() {
                              selectedWilaya = newValue!;
                            });
                          },
                          items: <String>[
                            'عنابة',
                            'قسنطينة',
                            'الجزائر',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            hintText: 'اختر ولايتك',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => showConfirmationDialog(context),
                    child: Text('متابعة'),
                  ),
                ],
              ),
            ),
    );
  }



void showConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedOption;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('تأكيد البيانات'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('اختر نوع التسجيل'),
                  ListTile(
                    title: const Text('مستخدم عادي'),
                    leading: Radio<String>(
                      value: 'user',
                      groupValue: selectedOption,
                      onChanged: (String? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('مصلح سيارات'),
                    leading: Radio<String>(
                      value: 'mechanic',
                      groupValue: selectedOption,
                      onChanged: (String? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedOption == 'user') {
                           storeData(context);

                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    } else if (selectedOption == 'mechanic') {
                           storeData(context);

                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const VehicleScreen()), // افترض أن RemoScreen هو اسم صفحة مصلح السيارات
                        (route) => false,
                      );
                    }
                  },
                  child: Text('تأكيد'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('إلغاء'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void storeData(BuildContext context) async {
    final ap = Provider.of<app_provider.AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      prename: prenameController.text.trim(),
      email: emailController.text.trim(),
      wilaya: selectedWilaya ?? '',
      phoneNumber: FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toMap(), SetOptions(merge: true))    //merge
        .then((_) {
      ap.saveUserData(
        context: context,
        userModel: userModel,
        onSuccess: () {
          ap.saveUserDataToSP().then((value) => ap.setSignIn());
        },
      );
    }).catchError((e) {
      showSnackBar(context, e.message.toString());
    });
  }

}