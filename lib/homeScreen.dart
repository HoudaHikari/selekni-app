import 'dart:collection';
import 'package:app/staticScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/login/phoneAuthScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/login/phoneAuthScreen.dart';
import 'package:app/profileScreen.dart';
import 'package:app/map/map.dart';
import 'package:app/map/backgroundGPS.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:app/provider/auth_provider.dart' as app_provider;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'homeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //LocationService _locationService = LocationService();
  double _lat = 0;
  double _lon = 0;
  late app_provider.AuthProvider _authProvider;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _profileImageUrl =
      'https://static.vecteezy.com/system/resources/previews/019/879/186/large_2x/user-icon-on-transparent-background-free-png.png';

  List<String> catNames = [
    'احصائيات',
    'الملف الشخصي',
    'طلب مساعدة',
    'قائمة المصلحين',
    'افضل المصلحين',
    'اتصل بنا',
  ];

  List<Color> catColors = [
    Color.fromARGB(255, 255, 214, 33),
    Color.fromARGB(255, 64, 194, 255),
    Color.fromARGB(255, 255, 105, 59),
    Color.fromARGB(255, 72, 196, 23),
    Color.fromARGB(255, 142, 39, 238),
    Color.fromARGB(255, 218, 48, 99),
  ];

  List<Icon> catIcons = [
    Icon(Icons.pie_chart, color: Colors.white, size: 30),
    Icon(Icons.person, color: Colors.white, size: 30),
    Icon(Icons.add, color: Colors.white, size: 30),
    Icon(Icons.local_shipping, color: Colors.white, size: 30),
    Icon(Icons.star, color: Colors.white, size: 30),
    Icon(Icons.email, color: Colors.white, size: 30),
  ];

  @override
  void initState() {
        requestLocationPermission();

    updateCurrentUserLocation();
    super.initState();


    _authProvider =
        Provider.of<app_provider.AuthProvider>(context, listen: false);
  }


Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
     await  updateCurrentUserLocation();
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are denied')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied. Please enable them from settings.')),
      );
      openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected permission status')),
      );
    }
  }


Future<void> updateCurrentUserLocation() async {
  // Get the current user's location
  geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
    desiredAccuracy: geolocator.LocationAccuracy.high,
  );

  // Update the user's location in Firestore
String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "No user";
  await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
    'userpos': GeoPoint(position.latitude, position.longitude),
  });
}

  getActivityProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _lat = (doc.data() as Map<String, dynamic>)['lat']?.toDouble() ?? 0.0;
        _lon = (doc.data() as Map<String, dynamic>)['lon']?.toDouble() ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Container(),
        title: Text(
          '',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
          child: Column(
            children: [
                DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.blue,
                    Colors.purple,
                  ]),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_profileImageUrl),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'الحساب الشخصي',
                  style: TextStyle(color: Colors.black87),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, ProfileScreen.id);
                },
              ),
              ListTile(
                title: Text(
                  'البحث عن مصلح',
                  style: TextStyle(color: Colors.black87),
                ),
                onTap: () {
                                     Navigator.pushReplacementNamed(context, MapScreen.id);

                  // Navigator.pushReplacementNamed(context, MapScreen.id);
                  //_locationService.sendLocationTodatabase(context);
                  //_locationService.goToMaps(_lat, _lon);
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _authProvider.logout(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'البحث عن مساعدين...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 25,
                  ),
                ),
              ),
            ),
          Expanded(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: 6,
          physics: ScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (BuildContext context, index) {
            return GestureDetector(
              onTap: () {
                switch (index) {
                  case 0:
                      Navigator.pushReplacementNamed(context, StatisticsPage.id);

                    break;
                  case 1:
                      Navigator.pushReplacementNamed(context, ProfileScreen.id);

                    break;
                  case 2:
                      Navigator.pushReplacementNamed(context, MapScreen.id);

                    break;
                  case 3:

                    break;
                  case 4:

                    break;
                  case 5:

                    break;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: catColors[index],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: catIcons[index],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    catNames[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


