import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'map/mapRemo.dart';
import 'map/map2.dart';

import 'profileRemoScreen.dart';
import 'package:app/staticScreen.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/provider/auth_provider.dart' as app_provider;
import 'package:provider/provider.dart';


class HomeRemoScreen extends StatefulWidget {
  static const id = 'homeRemoScreen';

  @override
  _HomeRemoScreenState createState() => _HomeRemoScreenState();
}


class _HomeRemoScreenState extends State<HomeRemoScreen> {
    late app_provider.AuthProvider _authProvider;

  List<Map<String, dynamic>> requests = [];
  late String currentUserPhoneNumber = ''; // تخزين رقم الهاتف للمستخدم الحالي

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
        fetchRequests();
        super.initState();

        fetchCurrentUserPhoneNumber();
     _authProvider =
        Provider.of<app_provider.AuthProvider>(context, listen: false);
  }

Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
     await  updateCurrentUserLocation();
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض أذونات الموقع')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض أذونات الموقع بشكل دائم. يرجى تمكينها من الإعدادات.')),
      );
      openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حالة الإذن غير متوقعة')),
      );
    }
  }


Future<void> updateCurrentUserLocation() async {
  // Get the current user's location
  geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
    desiredAccuracy: geolocator.LocationAccuracy.high,
  );

  // Update the user's location in Firestore
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
    'userpos': GeoPoint(position.latitude, position.longitude),
  });
}

   Future<void> fetchCurrentUserPhoneNumber() async {
    // جلب معرف المستخدم الحالي من Firebase Auth
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // جلب رقم الهاتف للمستخدم الحالي من Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    setState(() {
      currentUserPhoneNumber = userSnapshot['phoneNumber'];
    });
  }

  Future<void> fetchRequests() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('demande').get();
    setState(() {
      requests = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<LatLng> getCurrentUserLocation() async {
    geolocator.Position position =
        await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
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
                title: Text('الحساب الشخصي'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, ProfileRemoScreen.id);
                },
              ),
              ListTile(
                title: Text('البحث عن مصلح'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, Map2Screen.id);
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
                      Navigator.pushReplacementNamed(context, ProfileRemoScreen.id);

                    break;
                  case 2:
                      Navigator.pushReplacementNamed(context, Map2Screen.id);

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
         Expanded(
  child: RefreshIndicator(
    onRefresh: fetchRequests,
    child: requests.isEmpty
        ? Center(
            child: Text(
              'لا توجد طلبات في الوقت الحالي',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              GeoPoint helpPos = request['helppos'];
              if (request['remophone'] != currentUserPhoneNumber) {
                return SizedBox.shrink(); // لا تعرض شيء إذا كان هناك طلبات لم تتطابق مع رقم الهاتف الحالي
              }
              return GestureDetector(
                onTap: () async {
                  LatLng currentUserPosition = await getCurrentUserLocation();
                  LatLng helpPosition = LatLng(helpPos.latitude, helpPos.longitude);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapRemoScreen(
                        currentUserPosition: currentUserPosition,
                        helpPosition: helpPosition,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text('طلب من ${request['userName']}'),
                    subtitle: Text('وزن سيارته : ${request['usertypev']}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              );
            },
          ),
  ),
),
          ],
        ),
      ),
    );
  }
}