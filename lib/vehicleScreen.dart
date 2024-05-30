import 'package:flutter/material.dart';
import 'package:app/login/phoneAuthScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/login/phoneAuthScreen.dart';
import 'package:app/profileScreen.dart';
import 'package:app/homeRemoScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:app/provider/auth_provider.dart' as app_provider;
import 'package:provider/provider.dart';

class VehicleScreen extends StatefulWidget {
  static const id = 'vehicleScreen';

  const VehicleScreen({Key? key}) : super(key: key);

   @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}
class _VehicleScreenState extends State<VehicleScreen> {
    String carType = ''; // قيمة تخزين نوع السيارة
    String carNumberPlate = ''; // قيمة تخزين لوحة السيارة
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
        String? selectedCarType;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معلومات المركبة'),
      ),
     body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              DropdownButtonFormField<String>(
              value: selectedCarType,
  onChanged: (newValue) {
         setState(() {
      selectedCarType = newValue; // تحديث القيمة المحددة
      carType = newValue ?? ''; // تحديث قيمة نوع السيارة
    });
  },
                  items: <String>[
                    'plateau',
                    'traditionnel',
                    'semi-remorque',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'نوع السيارة'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى اختيار نوع السيارة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    carNumberPlate = value;
                  },
                  decoration: InputDecoration(labelText: 'رقم لوحة السيارة'),
                  validator: (value) {
                   if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم لوحة السيارة';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'يجب أن يتكون رقم لوحة السيارة من أرقام فقط';
    }
    if (value.length != 10) {
      return 'يجب أن يتكون رقم لوحة السيارة من 10 أرقام';
    }
    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveDataToDatabase(carType, carNumberPlate, userId);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeRemoScreen(),
                        ),
                      );
                    }
                  },
                  child: Text('متابعة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _saveDataToDatabase(String carType, String carNumberPlate, String userId) {
  // استعداد بيانات المستخدم وبيانات السيارة للتسجيل في قاعدة البيانات
  Map<String, dynamic> userData = {
    'carType': carType,
    'matricule': carNumberPlate,
  };

  // الحصول على مرجع لمستند المستخدم في قاعدة البيانات
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // إضافة بيانات السيارة إلى مستند المستخدم
  userDocRef.update(userData)
      .then((value) => print("تم تسجيل بيانات السيارة بنجاح"))
      .catchError((error) => print("فشل في تسجيل بيانات السيارة: $error"));
}
}