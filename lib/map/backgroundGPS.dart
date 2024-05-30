/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BackgroundLocationService extends StatefulWidget {
    static const id = 'backgroundGPS';

  const BackgroundLocationService({Key? key}) : super(key: key);

  @override
  _BackgroundLocationServiceState createState() =>
      _BackgroundLocationServiceState();
}

class _BackgroundLocationServiceState extends State<BackgroundLocationService> {
  late StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    startLocationService();
  }

  @override
  void dispose() {
    super.dispose();
    _positionStreamSubscription.cancel();
  }

  Future<void> startLocationService() async {
    // Request location permissions
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      return;
    }

    // Start listening to location updates
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
      // Update current user's location in Firestore
      await updateCurrentUserLocation(position);

      // Update nearest user's location in Firestore
      await updateNearestUserLocation(position);
    });
  }

  Future<void> updateCurrentUserLocation(Position position) async {
    // Update current user's location in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc('currentUserId')
        .update({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  Future<void> updateNearestUserLocation(Position position) async {
    // Query nearest user's location from Firestore
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Find nearest user and update their location in Firestore
    // Your logic to find nearest user goes here
    // For example, you could calculate distances and find the user with the smallest distance
    // Once you find the nearest user, update their location in Firestore
  }

  @override
  Widget build(BuildContext context) {
    // You can build a UI here to display any relevant information
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Location Service'),
      ),
      body: Center(
        child: Text('Service is running in the background...'),
      ),
    );
  }
}
*/





    /* try {
      final currentUser = FirebaseAuth.instance.currentUser;
       if (currentUser != null) {
        // احصل على مستند المستخدم
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        // احصل على قيمة pay الحالية
        DocumentSnapshot userSnapshot = await userDocRef.get();
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?; // قم بتحويل البيانات إلى Map<String, dynamic>
        int currentPay = userData?['pay'] ?? 0; // استخدم النوع int مباشرة
        // قم بتحديث pay بإضافة 100 إليه
        await userDocRef.update({'pay': currentPay + 100});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث قيمة pay بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('المستخدم غير موجود')),
        );
      }
    } catch (error) {
      print('حدث خطأ أثناء تحديث قيمة pay: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث قيمة pay')),
      );
    }
  

*/