import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart' as app_provider;
import 'package:app/homeRemoScreen.dart';


class ProfileRemoScreen extends StatefulWidget {
  static const id = 'profileRemoScreen';

  @override
  _ProfileRemoScreenState createState() => _ProfileRemoScreenState();
}

class _ProfileRemoScreenState extends State<ProfileRemoScreen> {
  late String _profileImageUrl = 'https://static.vecteezy.com/system/resources/previews/019/879/186/large_2x/user-icon-on-transparent-background-free-png.png';
  String? _selectedWeight;
 final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<app_provider.AuthProvider>(context, listen: false);
return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('الملف الشخصي'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
                        Navigator.pushReplacementNamed(context, HomeRemoScreen.id);
            },
          ),
        ),
        body: Center(
        child: ap.userModel != null
            ? ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topCenter,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(_profileImageUrl),
                    ),
                  ),
                  SizedBox(height: 20),
                  buildProfileItem('الاسم', ap.userModel!.name),
                  buildProfileItem('اللقب', ap.userModel!.prename),
                  buildProfileItem('البريد الالكتروني', ap.userModel!.email),
                  buildProfileItem('رقم الهاتف', ap.userModel!.phoneNumber),
                  buildProfileItem('الولاية', ap.userModel!.wilaya),
                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'نوع السيارة',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
    SizedBox(height: 4),
    StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        String carType = userData['carType'] ?? '';
        return Text(
          carType,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        );
      },
    ),
    SizedBox(height: 16),
    Text(
      'الماتريكول',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
    SizedBox(height: 4),
    StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        String matricule = userData['matricule'] ?? '';
        return Text(
          matricule,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        );
      },
    ),
  ],
),
                  buildWeightDropdown(),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (_selectedWeight != null) {
                        updateUserWeight(_selectedWeight!);
                      }
                    },
                    child: Text('تحديث'),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
        ),
    );
  }

  Widget buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeightDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوزن',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4),
        DropdownButton<String>(
          value: _selectedWeight,
          onChanged: (newValue) {
            setState(() {
              _selectedWeight = newValue;
            });
          },
          items: [
            DropdownMenuItem(
              child: Text('وزن 1'),
              value: 'وزن 1',
            ),
            DropdownMenuItem(
              child: Text('وزن 2'),
              value: 'وزن 2',
            ),
            DropdownMenuItem(
              child: Text('وزن 3'),
              value: 'وزن 3',
            ),
          ],
        ),
      ],
    );
  }

  void updateUserWeight(String weight) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'type_V': weight});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحديث الوزن بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('المستخدم غير موجود')),
        );
      }
    } catch (error) {
      print('خطأ في تحديث وزن السيارة: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث الوزن')),
      );
    }
  }
  
}
