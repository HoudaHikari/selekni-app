import 'dart:collection';
import 'package:app/staticScreen.dart';

import 'map/mapRemo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app/login/userInfoScreen.dart';
import 'package:app/vehicleScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart'
    as app_provider; // Use 'as' keyword to provide a prefix
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:app/login/loginscreen.dart';
import 'package:app/login/otpScreen.dart';
import 'package:app/login/phoneAuthScreen.dart';
import 'package:app/homeScreen.dart';
import 'package:app/homeRemoScreen.dart';
import 'package:app/map/map.dart';
import 'package:app/map/map2.dart';
import 'package:app/map/backgroundGPS.dart';
import 'package:app/profileRemoScreen.dart';
import 'package:app/profileScreen.dart';
import 'package:app/login/welcomescreen.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAvvH1co38yRjg97EczmNl9OWIMjfqPVFo",
          appId: "1:342536120196:android:68e740057e353ed32f5fd1",
          messagingSenderId: "342536120196",
          projectId: "selekni-e7da2",
          ),
          )
  ;
  await FirebaseAppCheck.instance.activate(
    
    
    androidProvider: AndroidProvider.debug,
    
  
  );


  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                app_provider.AuthProvider()), // Use the prefix 'app_provider'
      ],
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          HomeScreen.id: (context) => const HomeScreen(),
          HomeRemoScreen.id: (context) =>  HomeRemoScreen(),
          VehicleScreen.id: (context) => const VehicleScreen(),
          MapScreen.id: (context) => const MapScreen(),
          Map2Screen.id: (context) => const Map2Screen(),
            //      BackgroundLocationService.id: (context) => const BackgroundLocationService(),
          //LoginScreen.id: (context) => const LoginScreen(),
          PhoneAuthScreen.id: (context) => const PhoneAuthScreen(),
          ProfileScreen.id: (context) => ProfileScreen(),
        ProfileRemoScreen.id: (context) => ProfileRemoScreen(),
          UserInfoScreen.id: (context) =>  UserInfoScreen(),
          MapRemoScreen.id: (context) => MapRemoScreen(
             currentUserPosition: LatLng(0, 0), 
                helpPosition: LatLng(0, 0),    ),
          StatisticsPage.id: (context) =>  StatisticsPage(),
       



        },
      ),
    );
  }
}
