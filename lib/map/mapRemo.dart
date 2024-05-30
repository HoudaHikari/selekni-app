import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/homeRemoScreen.dart';



class MapRemoScreen extends StatefulWidget {
  static const id = 'mapRemoScreen';
  final LatLng currentUserPosition;
  final LatLng helpPosition;

  MapRemoScreen({
    required this.currentUserPosition,
    required this.helpPosition,
  });

  @override
  _MapRemoScreenState createState() => _MapRemoScreenState();
}

class _MapRemoScreenState extends State<MapRemoScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
    String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _getPolyline();
      _getPhoneNumber();

  }

  void _setMarkers() {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('currentUser'),
        position: widget.currentUserPosition,
        infoWindow: InfoWindow(title: 'موقعك الحالي'),
      ));
      markers.add(Marker(
        markerId: MarkerId('helpPosition'),
        position: widget.helpPosition,
        infoWindow: InfoWindow(title: 'الشخص المطلوب'),
      ));
    });

    _moveCameraToIncludeBothLocations();
  }

  Future<void> _moveCameraToIncludeBothLocations() async {
    final GoogleMapController controller = await _controller.future;

    LatLngBounds bounds;
    if (widget.currentUserPosition.latitude > widget.helpPosition.latitude) {
      bounds = LatLngBounds(
        southwest: widget.helpPosition,
        northeast: widget.currentUserPosition,
      );
    } else {
      bounds = LatLngBounds(
        southwest: widget.currentUserPosition,
        northeast: widget.helpPosition,
      );
    }

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> _getPolyline() async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.currentUserPosition.latitude},${widget.currentUserPosition.longitude}&destination=${widget.helpPosition.latitude},${widget.helpPosition.longitude}&key=YOUR_API_KEY';

    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> data = jsonDecode(response.body);

    if (data['routes'].isNotEmpty) {
      String points = data['routes'][0]['overview_polyline']['points'];
      polylineCoordinates = _decodePolyline(points);
      
      setState(() {
        polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          width: 6,
          color: Colors.blue,
        ));
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

   Future<void> _cancelOrder() async {
  try {
    await FirebaseFirestore.instance
        .collection('demande')
        .where('helppos', isEqualTo: GeoPoint(widget.helpPosition.latitude, widget.helpPosition.longitude))
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  } catch (e) {
    print('Error cancelling order: $e');
  }
}

  Future<void> _getPhoneNumber() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('demande')
          .where('helppos', isEqualTo: GeoPoint(widget.helpPosition.latitude, widget.helpPosition.longitude))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          phoneNumber = querySnapshot.docs.first['userphone'];
        });
      }
    } catch (e) {
      print('Error getting phone number: $e');
    }
  }

 Future<void> _updateOrderStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('demande')
          .where('helppos', isEqualTo: GeoPoint(widget.helpPosition.latitude, widget.helpPosition.longitude))
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({'status': 'en preparation'});
        }
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.currentUserPosition,
              zoom: 15,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
  Positioned(
  left: 0,
  right: 0,
  bottom: 0,
  child: Container(
    padding: EdgeInsets.all(10),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
              await _updateOrderStatus();

            launch('tel:$phoneNumber');
            Navigator.pushReplacementNamed(context, HomeRemoScreen.id);


          },
          child: Text('اتصال'),
        ),
        ElevatedButton(
          onPressed: () async {

            
            await _cancelOrder();

                        Navigator.pushReplacementNamed(context, HomeRemoScreen.id);
          },
          child: Text('الغاء الطلب'),
        ),
      ],
    ),
  ),
),
],
),
);
}

}