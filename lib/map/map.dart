import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/homeScreen.dart';

class MapScreen extends StatefulWidget {
  static const id = 'mapScreen';

  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentUserPosition;
  LatLng? nearestUserPosition;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  OverlayEntry? _overlayEntry;
  DocumentReference? currentRequestRef;


  @override
  void initState() {
    super.initState();
    requestLocationPermission();

  }

  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      await getCurrentLocation();
      await findNearestUser();
    } else {
      String message = status.isDenied
          ? 'Location permissions are denied'
          : 'Unexpected permission status';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      geolocator.Position position =
          await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      setState(() {
        currentUserPosition = LatLng(position.latitude, position.longitude);
        markers.add(
          Marker(
            markerId: const MarkerId('currentUser'),
            position: currentUserPosition!,
            infoWindow: const InfoWindow(title: 'موقعك'),
          ),
        );
      });

      _moveCameraToIncludeBothUsers();
    } catch (e) {
      print(e);
    }
  }

  Future<void> moveCameraToCurrentUser() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentUserPosition!,
        zoom: 15,
      ),
    ));
  }

  void showNoNearbyUserDialog() {
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'لا يوجد مستخدم قريب حاليًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, HomeScreen.id);
                  },
                  child: Text('رجوع'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  
  Future<void> findNearestUser() async {
    if (currentUserPosition == null) {
      print('Current user position is null');
      return;
    }

    double userLatitude = currentUserPosition!.latitude;
    double userLongitude = currentUserPosition!.longitude;

    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    if (usersSnapshot.docs.isNotEmpty) {
      double minDistance = double.infinity;
      String nearestUserId = ''; // تخزين معرف المستخدم الأقرب
      LatLng? nearestUserPos;

      for (var doc in usersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['userpos'] != null &&
            data['uid'] != FirebaseAuth.instance.currentUser?.uid) {
          // تجاهل المستخدم الحالي
          GeoPoint userPos = data['userpos'] as GeoPoint;

          // التحقق من وجود cartype غير مساوٍ لـ null
          if (data['carType'] != null) {
            double distance = geolocator.Geolocator.distanceBetween(
              userLatitude,
              userLongitude,
              userPos.latitude,
              userPos.longitude,
            );

            if (distance < minDistance) {
              minDistance = distance;
              nearestUserId = doc.id; // تحديث معرف المستخدم الأقرب
              nearestUserPos = LatLng(userPos.latitude, userPos.longitude);
            }
          }
        }
      }

      if (nearestUserPos != null) {

        setState(() {
          nearestUserPosition = nearestUserPos;
          markers.add(
            Marker(
              markerId: const MarkerId('nearestUser'),
              position: nearestUserPosition!,
              infoWindow: const InfoWindow(title: 'اقرب مصلح'),
            ),
          );
        });

                        _moveCameraToIncludeBothUsers();



        var nearestUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(nearestUserId)
            .get();
        var nearestUserData = nearestUserDoc.data() as Map<String, dynamic>;

        // Check if there's an existing request for the current user
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        QuerySnapshot existingRequestSnapshot = await FirebaseFirestore.instance
            .collection('demande')
            .where('userphone', isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber)
            .get();

        if (existingRequestSnapshot.docs.isNotEmpty) {
          var requestData = existingRequestSnapshot.docs.first.data() as Map<String, dynamic>;
          if (requestData['status'] == 'en attent') {
            // If there is a request with status 'en attent', show the waiting overlay
            setState(() {
              currentRequestRef = existingRequestSnapshot.docs.first.reference;
              _moveCameraToIncludeBothUsers();
              _showWaitingOverlay(context);
            });
            return;
          } else if (requestData['status'] == 'en preparation') {
            // If there is a request with status 'en preparation', show the preparation overlay
            setState(() {
              currentRequestRef = existingRequestSnapshot.docs.first.reference;
              _moveCameraToIncludeBothUsers();
              _showPreparationOverlay(context);
            });
            return;
          }
        }

        // التحقق مرة أخرى من وجود cartype غير مساوٍ لـ null
        if (nearestUserData['carType'] != null) {
          _showOverlay(context, nearestUserData, nearestUserId);
        }

      } else {
        print('No nearest user found');
        moveCameraToCurrentUser(); // تحريك الكاميرا إلى موقع المستخدم الحالي
        showNoNearbyUserDialog(); // عرض النافذة المنبثقة برسالة لا يوجد مستخدم قريب
      }
    } else {
      print('No users found in the database');
    }
  }

  void _moveCameraToIncludeBothUsers() async {
    if (currentUserPosition == null || nearestUserPosition == null) {
      return;
    }

    final GoogleMapController controller = await _controller.future;

    LatLngBounds bounds;
    if (currentUserPosition!.latitude > nearestUserPosition!.latitude) {
      bounds = LatLngBounds(
        southwest: nearestUserPosition!,
        northeast: currentUserPosition!,
      );
    } else {
      bounds = LatLngBounds(
        southwest: currentUserPosition!,
        northeast: nearestUserPosition!,
      );
    }

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _showWaitingOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'طلبك قيد الانتظار',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                      try {
                      await FirebaseFirestore.instance
                          .collection('demande')
                          .where('userphone', isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber)
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        querySnapshot.docs.forEach((doc) {
                          doc.reference.delete();
                        });
                      });
                    } catch (e) {
                      print('Error finishing order: $e');
                    }
                    
                      _overlayEntry?.remove();
                    _overlayEntry = null;
                                            Navigator.pushReplacementNamed(context, HomeScreen.id);
                  },
                  child: Text('إلغاء الطلب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

final OverlayState? overlayState = Overlay.of(context);
if (overlayState != null) {
  overlayState.insert(_overlayEntry!);
}
  }


   void _showPreparationOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المساعدة قادمة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
  onPressed: () async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String? remophone;
        QuerySnapshot demandeSnapshot = await FirebaseFirestore.instance
            .collection('demande')
            .where('userphone', isEqualTo: currentUser.phoneNumber)
            .get();

        if (demandeSnapshot.docs.isNotEmpty) {
          var demandeData = demandeSnapshot.docs.first.data() as Map<String, dynamic>;
          remophone = demandeData['remophone'];
        }

        if (remophone != null) {
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: remophone)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            DocumentReference userDocRef = userSnapshot.docs.first.reference;
            Map<String, dynamic>? userData = userSnapshot.docs.first.data() as Map<String, dynamic>?;
            int currentPay = userData?['pay'] ?? 0;

            await userDocRef.update({'pay': currentPay + 100});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تمت العملية بنجاح')),
            );

            // زيادة قيمة nb_demande للمستخدم بمقدار واحد
            await userDocRef.update({'nb_demande': FieldValue.increment(1)});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('المستخدم غير موجود')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('رقم الهاتف الخاص بالمستخدم المصلح غير موجود')),
          );
        }
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

    try {
      await FirebaseFirestore.instance
          .collection('demande')
          .where('userphone', isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    } catch (e) {
      print('Error finishing order: $e');
    }

    _overlayEntry?.remove();
    _overlayEntry = null;
    Navigator.pushReplacementNamed(context, HomeScreen.id);
  },
  child: Text('تم'),
),
              ],
            ),
          ),
        ),
      ),
    );

final OverlayState? overlayState = Overlay.of(context);
if (overlayState != null) {
  overlayState.insert(_overlayEntry!);
}  }


  void _showOverlay(
      BuildContext context, Map<String, dynamic> nearestUserData, String nearestUserId) async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    var currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    var currentUserData = currentUserDoc.data() as Map<String, dynamic>;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الإسم: ${nearestUserData['name']}'),
                Text('اللقب: ${nearestUserData['prename']}'),
                Text('نوع السيارة: ${nearestUserData['carType']}'),
                Text('رقم هاتفه: ${nearestUserData['phoneNumber']}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                                QuerySnapshot existingRequestSnapshot = await FirebaseFirestore.instance
                                  .collection('demande')
                                 .where('userphone', isEqualTo: FirebaseAuth.instance.currentUser?.phoneNumber)
                              .get();

                          _showWaitingOverlay(context);

                        DocumentReference demandeRef = await FirebaseFirestore.instance.collection('demande').add({
                          'userName': currentUserData['name'],
                          'userphone': FirebaseAuth.instance.currentUser?.phoneNumber,
                          'usertypev': currentUserData['type_V'],
                          'remophone': nearestUserData['phoneNumber'],
                          'remoname': nearestUserData['name'],
                          'remoprename': nearestUserData['prename'],
                          'carType': nearestUserData['carType'],
                          'helppos': GeoPoint(currentUserPosition!.latitude, currentUserPosition!.longitude),
                          'remopos': GeoPoint(nearestUserPosition!.latitude, nearestUserPosition!.longitude),
                          'timestamp': FieldValue.serverTimestamp(),
                          'status': 'en attent',
                        });

                        

                      },
                      child: Text('طلب'),
                    ),
                    TextButton(
                      onPressed: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                        Navigator.pushReplacementNamed(context, HomeScreen.id);
                      },
                      child: Text('إلغاء'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

final OverlayState? overlayState = Overlay.of(context);
if (overlayState != null) {
  overlayState.insert(_overlayEntry!);
}  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(''),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          Navigator.pushReplacementNamed(context, HomeScreen.id);
        },
      ),
    ),
    body: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentUserPosition ?? LatLng(0, 0),
            zoom: 15,
          ),
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ],
    ),
  );
}
}