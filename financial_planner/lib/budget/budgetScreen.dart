import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../notification.dart';
import 'addBudget.dart';
import 'budgetInfo.dart';
import 'package:timezone/data/latest.dart' as tz;

class BudgetScreen extends StatefulWidget {
  final String? userId;

  BudgetScreen({this.userId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  Stream<QuerySnapshot>? _budgetStream;
  List <Color> colors = [
    Color(0xFFFFFFB3),
    Color(0xFFFFCC80),
    Color(0xFFD0FFC9),
    Color(0xFFFFB6C1)
  ];
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    getBudgets();
    tz.initializeTimeZones();
  }

  void getBudgets() async {
    Stream<QuerySnapshot>? _budgets = await _getBudgets(widget.userId);

    setState(() {
      _budgetStream = _budgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_budgetStream == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Budgets"),
          backgroundColor: Colors.purple[100],
        ),
        body: Center(
          //child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  StreamBuilder<QuerySnapshot>(
                      stream: _budgetStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.data != null &&
                            snapshot.data!.docs.isEmpty) {
                          return Text(
                            "Looks like you don't have any Budgets right now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading');
                        }
                        return Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children:
                              snapshot.data!.docs.map((
                                  DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                                colorIndex++;
                                if(colorIndex == 4){
                                  colorIndex = 0;
                                }
                                double remaining = data['amount'] -
                                    data['amountUsed'];

                                if(remaining != null && remaining <=100){
                                  NotificationService().showNotification(
                                      1,
                                      "Budget: ${data['name']}" ,
                                      " \$\ ${remaining} remaining until ${data['endDate'].toDate()} "
                                  );
                                }

                                return Container(
                                    width: 200,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      children: [
                                        GestureDetector(
                                          child:
                                          Container(
                                            height: 150,
                                            width: 350,
                                            decoration: BoxDecoration(
                                                color: colors[colorIndex],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: ListTile(
                                                title: Text(
                                                  data['name'] +
                                                      "\n\$\ " +
                                                      (remaining)
                                                          .toString() +
                                                      " remaining",
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                    data['description'])
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BudgetInfo(
                                                          budgetId: data['id'],
                                                          userId: widget
                                                              .userId,)),
                                                    (route) => false);
                                          },
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ));
                              }).toList(),
                            ));
                      }),
                ]
            )
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.purple[100],
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddBudget(
                          userId: widget.userId,
                        )),
                    (route) => false);
          },
          label: Text('Add Budget'),
          icon: Icon(Icons.add),
        ),
      );
    }
  }

  Future<Stream<QuerySnapshot>> _getBudgets(String? id) async {
    Stream<QuerySnapshot> budgets = await FirebaseFirestore.instance
        .collection('Budgets')
        .where('userId', isEqualTo: id)
        .snapshots();

    return budgets;
  }
}
