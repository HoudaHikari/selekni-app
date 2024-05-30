import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/homeScreen.dart';

class StatisticsPage extends StatefulWidget {
  static const id = 'statisticsScreen';

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إحصائيات عدد الطلبات'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, HomeScreen.id);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            Map<String, int> statistics = {};
            int totalDemande = 0;

            snapshot.data!.docs.forEach((userDoc) {
              String? wilaya = userDoc['wilaya'];
              if (wilaya != null) {
                // التحقق من وجود الحقل 'nb_demande' باستخدام التحقق من القيمة
                var data = userDoc.data();
                if (data != null && data.containsKey('nb_demande')) {
                  int nbDemande = data['nb_demande'];
                  statistics.update(wilaya, (value) => value + nbDemande, ifAbsent: () => nbDemande);
                  totalDemande += nbDemande;
                }
              }
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'العدد الإجمالي للطلبات: $totalDemande',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'إحصائيات عدد الطلبات في كل ولاية',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: statistics.length,
                      itemBuilder: (context, index) {
                        String wilaya = statistics.keys.elementAt(index);
                        int nbDemande = statistics[wilaya]!;
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Text('$wilaya: $nbDemande'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
