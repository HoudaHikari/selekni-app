/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/homeScreen.dart';
import 'package:app/profileScreen.dart';

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final Future<User?> user;

  FirebaseService() {
    user = _auth.authStateChanges().first.then((User? user) {
      if (user != null) {
        return _db.collection('users').doc(user.uid).get().then(
              (DocumentSnapshot<Map<String, dynamic>> snapshot) => user,
            );
      } else {
        return null;
      }
    });
  }

  Future<User?> googleSignIn(BuildContext context, String phoneNumber) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final authResult = await _auth.signInWithCredential(credential);
    if (authResult.user != null) {
  await updateGoogleUserProfile(authResult.user!);
  Navigator.pushReplacementNamed(context, HomeScreen.id);
}
      print('signed in' + authResult.user!.displayName!);
      return authResult.user;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

Future<void> updateGoogleUserProfile(User user) async {
  try {
    DocumentReference userRef = _db.collection('users').doc(user.uid);
   if (user != null) {
      String? phoneNumber = await getUserPhoneNumber(user.uid);
      String? updatedPhoneNumber = phoneNumber != null ? null : phoneNumber;
      Map<String, dynamic> userData = {
        'phoneNumber': updatedPhoneNumber,
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastSeen': DateTime.now(),// تعيين رقم الهاتف على قيمة null
        // يمكنك إضافة المزيد من البيانات هنا
      };
await userRef.set(userData, SetOptions(merge: true));
      print('تم تحديث بيانات المستخدم من غوغل بنجاح');
    } else {
      print('حدث خطأ: لم يتم العثور على مستخدم حالي');
    }
  } catch (error) {
    print('حدث خطأ أثناء تحديث بيانات المستخدم من غوغل: $error');
  }
}
Future<String?> getUserPhoneNumber(String uid) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _db.collection('users').doc(uid).get();
    return snapshot.data()?['phoneNumber']; // إرجاع رقم الهاتف من الوثيقة
  } catch (error) {
    print('حدث خطأ أثناء استرداد رقم الهاتف: $error');
    return null;
  }
}

Future<void> updatePhoneNumber(String uid, String phoneNumber) async {
  try {
    DocumentReference userRef = _db.collection('users').doc(uid);
    if (uid != null) {
      Map<String, dynamic> userData = {
        'phoneNumber': phoneNumber, // تحديث رقم الهاتف فقط
      };
      await userRef.update(userData);
      print('تم تحديث رقم الهاتف بنجاح');
    } else {
      print('حدث خطأ: لم يتم العثور على مستخدم حالي');
    }
  } catch (error) {
    print('حدث خطأ أثناء تحديث رقم الهاتف: $error');
  }
}
  void signOut() {
    _auth.signOut();
  }
}
*/