import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_planner/balance/incomeInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/Balance.dart';
import 'addIncome1.dart';

class BalanceScreen extends StatefulWidget {
  final String? userId;

  BalanceScreen({this.userId});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  num? balanceAmount;
  String? balanceId;
  Stream<QuerySnapshot>? _incomeStream;

  @override
  void initState() {
    super.initState();
    setBalance();
    setBalanceId();
  }

  void setBalanceId() async {
    String? id = await getBalanceIdById(widget.userId);
    setState(() {
      balanceId = id;
      getIncomes();
    });
  }

  void setBalance() async {
    num? amount = await getBalanceById(widget.userId);
    setState(() {
      balanceAmount = amount;
    });
  }

  void getIncomes() async {
    Stream<QuerySnapshot>? _incomes = await _getIncomes(balanceId);

    setState(() {
      _incomeStream = _incomes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Balance"),
      ),
      body: Center(
        //child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 100,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Account Balance",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$\ ${balanceAmount}",
                      style: TextStyle(
                          fontSize: 45,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 50,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Gained this month: x",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 50,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Monthly average: x",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            Text(
              "Incomes",
              style: TextStyle(fontSize: 24),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _incomeStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading');
                  }
                  return Expanded(
                      child: ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return Container(
                          width: 200,
                          child: Column(
                            children: [
                              GestureDetector(
                                child: Container(
                                  height: 80,
                                  width: 350,
                                  decoration: BoxDecoration(
                                      color: Colors.lightGreenAccent[100],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: ListTile(
                                      title: Text(data['title'] +
                                          " \n  \$\ " +
                                          data['amount'].toString()),
                                      subtitle: Text(data['description'])),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              IncomeInfo(id: data['id'])));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('A SnackBar has been shown.'),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ));
                    }).toList(),
                  ));
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AddIncome1(
                    userId: widget.userId,
                    balanceAmount: balanceAmount,
                  )),
                  (route) => false);
        },
        label: Text('Add Income'),
        icon: Icon(Icons.add),
      ),
      //)
    );
  }

  Future<num?> getBalanceById(String? id) async {
    num? balanceAmount;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        balanceAmount = balance.amount;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return balanceAmount;
  }

  Future<String?> getBalanceIdById(String? id) async {
    String? balanceId;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        balanceId = balance.id;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return balanceId;
  }

  Future<Stream<QuerySnapshot>> _getIncomes(String? id) async {
    Stream<QuerySnapshot> incomes = await FirebaseFirestore.instance
        .collection('Incomes')
        .where('balanceId', isEqualTo: id)
        .snapshots();

    return incomes;
  }
}
