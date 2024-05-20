import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_planner/balance/incomeInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/Balance.dart';
import '../models/Income.dart';
import 'addIncome1.dart';

class BalanceScreen extends StatefulWidget {
  final String? userId;

  BalanceScreen({this.userId});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  Stream<QuerySnapshot>? _balance;
  String? balanceId;
  Stream<QuerySnapshot>? _incomeStream;
  Stream<QuerySnapshot>? _thismonthsincomeStream;
  num? balanceAmount;

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
      setBalance();
      setThisMonthsIncomeStream();
    });
  }
  void setThisMonthsIncomeStream() async {
    Stream<QuerySnapshot>? incomes = await _getIncomesThisMonth(balanceId);
    setState(() {
      _thismonthsincomeStream = incomes;
    });
  }

  void setGainedThisMonth(String? balanceId, num amount) async {
      _updateBalance(balanceId,amount);
  }

  void setBalance() async {
    Stream<QuerySnapshot>? correctBalance = await getBalanceById(widget.userId);

    setState(() {
      _balance = correctBalance;
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
    if (_incomeStream == null || _balance == null ||
        _thismonthsincomeStream == null || balanceId == null ) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
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
                  StreamBuilder<QuerySnapshot>(
                      stream: _balance,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading');
                        }
                        return ListView(
                          shrinkWrap: true,
                          children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                            balanceId = data['id'];
                            balanceAmount = data['amount'];
                            return Container(
                              height: 150,
                              width: 350,
                              decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(20))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
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
                                    "\$\ ${data['amount'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontSize: 45,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
                  SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _thismonthsincomeStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading');
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      double totalAmount = 0;
                      snapshot.data!.docs.forEach((document) {
                        double amount = document['amount'];
                        totalAmount += amount;
                      });
                      setGainedThisMonth(balanceId, totalAmount);

                      return
                        Container(
                            height: 50,
                            width: 350,
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Gained this month: \$${totalAmount
                                      .toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ));
                    },
                  ),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading');
                        }
                        return Expanded(
                            child:
                            ListView(
                              shrinkWrap: true,
                              children:
                              snapshot.data!.docs.map((
                                  DocumentSnapshot document) {
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
                                                color: Colors
                                                    .lightGreenAccent[100],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: ListTile(
                                                title: Text(data['title'] +
                                                    " \n \$\ " +
                                                    data['amount'].toString()),
                                                subtitle: Text(
                                                    data['description'])),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IncomeInfo(
                                                            incomeId: data['id'], userId: widget.userId,)));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                Text(
                                                    'A SnackBar has been shown.'),
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
                      }),
                ])),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddIncome1(
                          userId: widget.userId,
                          balanceId: balanceId,
                          balanceAmount: balanceAmount,
                        )),
                    (route) => false);
          },
          label: Text('Add Income'),
          icon: Icon(Icons.add),
        ),
      );
    }
  }

  Future<Stream<QuerySnapshot>> getBalanceById(String? id) async {
    Stream<QuerySnapshot> balance = await FirebaseFirestore.instance
        .collection('Balances')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return balance;
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

  Future<num?> getBalanceAmountById(String? id) async {
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

  Future<Stream<QuerySnapshot>> _getIncomesThisMonth(String? id) async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
    Timestamp startTimestamp = Timestamp.fromDate(startOfMonth);
    Timestamp endTimestamp = Timestamp.fromDate(endOfMonth);

    Stream<QuerySnapshot> incomes = await FirebaseFirestore.instance
        .collection('Incomes')
        .where('balanceId', isEqualTo: id)
        .where('currentDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('currentDate', isLessThanOrEqualTo: endTimestamp)
        .snapshots();

    return incomes;
  }

  void _updateBalance(String? balanceId, num incomeThisMonth) async {
    DocumentReference balance = FirebaseFirestore.instance.collection(
        'Balances')
        .doc(balanceId);
    try {
      DocumentSnapshot snapshot = await balance.get();
      if (snapshot.exists) {
        await balance.update({
          'gainedThisMonth': incomeThisMonth,
        });
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  Future<Stream<QuerySnapshot>> _getIncomes(String? id) async {
    Stream<QuerySnapshot> incomes = await FirebaseFirestore.instance
        .collection('Incomes')
        .where('balanceId', isEqualTo: id)
        .snapshots();

    return incomes;
  }

  num getBalanceAmount(int amount) {
    balanceAmount = amount;
    return amount;
  }
}
