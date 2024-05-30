import 'dart:convert';

import 'package:app/login/user_model.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app/login/user_model.dart';
import 'package:app/homeScreen.dart';
import 'package:app/login/phoneAuthScreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/login/otpScreen.dart';
import 'package:app/utils/utils.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  bool get isUserSignedIn => _isSignedIn;


  late String _uid;
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  TextEditingController? _phoneTextController;

  AuthProvider() {
    checkSignIn();
      checkFirebaseAuthSignIn();
          fetchUserData();


  }

   Future<void> updateUserWeight(String newWeight) async {
    // تحديث قاعدة البيانات باستخدام Firebase Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'type_v': newWeight});
    }
  }

  void setPhoneTextController(TextEditingController phoneTextController) {
    _phoneTextController = phoneTextController;
  }



  void checkFirebaseAuthSignIn() {
    final user = _firebaseAuth.currentUser;
    _isSignedIn = user != null;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_signedin", false);  
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
      (route) => false,
    );
  }
  void checkSignIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool("isSignedIn") ?? false;
    notifyListeners();
  }


  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                verificationId: verificationId,
                phoneNumber: _phoneTextController!.text,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  
  }

  // Save user data here

  void saveUserData({
    required UserModel userModel,
    required Function onSuccess,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      String _uid = _firebaseAuth.currentUser!.uid;

      userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      userModel.uid = _uid;
      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap(), SetOptions(merge: true))
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      print("User data: ${doc.data()}"); // نقطة تصحيح

      _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }
  Future<void> saveUserDataToSP() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    if (_userModel != null) {
      await s.setString("user_model", jsonEncode(_userModel!.toMap()));
    } else {
      print("User model is null. Cannot save to SharedPreferences.");
    }
  }


}
