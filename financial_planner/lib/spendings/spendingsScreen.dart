import 'package:financial_planner/spendings/addSpending.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_planner/balance/incomeInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../models/Balance.dart';

class SpendingScreen extends StatefulWidget {
  final String? userId;

  SpendingScreen({this.userId});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  num? balanceAmount;
  String? balanceId;
  Stream<QuerySnapshot>? _balance;
  Stream<QuerySnapshot>? _spendingsStream;
  Stream<QuerySnapshot>? _thisMonthsSpendingsStream;

  @override
  void initState() {
    super.initState();
    setBalance();
    setBalanceId();
    setBalanceStream();
  }

  void setBalanceId() async {
    String? id = await getBalanceIdById(widget.userId);
    setState(() {
      balanceId = id;
      getIncomes();
      setThisMonthsSpendingsStream();
    });
  }

  void setThisMonthsSpendingsStream() async {
    Stream<QuerySnapshot>? spendings = await _getSpendingsThisMonth(balanceId);
    setState(() {
      _thisMonthsSpendingsStream = spendings;
    });
  }

  void setSpentThisMonth(String? balanceId, num amount) async {
    _updateBalance(balanceId,amount);
  }

  void setBalance() async {
    num? amount = await getBalanceAmountById(widget.userId);
    setState(() {
      balanceAmount = amount;
    });
  }

  void setBalanceStream() async {
    Stream<QuerySnapshot>? correctBalance = await getBalanceById(widget.userId);

    setState(() {
      _balance = correctBalance;
    });
  }

  void getIncomes() async {
    Stream<QuerySnapshot>? _incomes = await _getSpendings(balanceId);

    setState(() {
      _spendingsStream = _incomes;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_spendingsStream == null || _balance == null ||
        _thisMonthsSpendingsStream == null || balanceId == null) {
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                stream: _thisMonthsSpendingsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading');
                  }

                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                  }
                  double totalAmount = 0;
                  snapshot.data!.docs.forEach((document) {
                    double amount = document['amount'];
                    totalAmount += amount;
                  });
                  setSpentThisMonth(balanceId, totalAmount);
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
                              "Spent this month: \$${totalAmount
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
                "Spendings",
                style: TextStyle(fontSize: 24),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: _spendingsStream,
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
                                    Container(
                                      height: 80,
                                      width: 350,
                                      decoration: BoxDecoration(
                                          color: Colors.pinkAccent[100],
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(20))),
                                      child: ListTile(
                                          title: Text(data['title'] +
                                              " \n  \$\ " +
                                              data['amount'].toString()),
                                          subtitle: Text(data['description'])),
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
                    builder: (context) =>
                        AddSpending(
                          userId: widget.userId,
                          balanceAmount: balanceAmount,
                        )),
                    (route) => false);
          },
          label: Text('Add Spending'),
          icon: Icon(Icons.add),
        ),
      );
    }
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

  Future<Stream<QuerySnapshot>> _getSpendings(String? id) async {
    Stream<QuerySnapshot> spendings = await FirebaseFirestore.instance
        .collection('Spendings')
        .where('balanceId', isEqualTo: id)
        .snapshots();

    return spendings;
  }

  void _updateBalance(String? balanceId, num spendingsThisMonth) async {
    DocumentReference balance = FirebaseFirestore.instance.collection(
        'Balances')
        .doc(balanceId);
    try {
      DocumentSnapshot snapshot = await balance.get();
      if (snapshot.exists) {
        await balance.update({
          'spentThisMonth': spendingsThisMonth,
        });
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  Future<Stream<QuerySnapshot>> _getSpendingsThisMonth(String? id) async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
    Timestamp startTimestamp = Timestamp.fromDate(startOfMonth);
    Timestamp endTimestamp = Timestamp.fromDate(endOfMonth);

    Stream<QuerySnapshot> incomes = await FirebaseFirestore.instance
        .collection('Spendings')
        .where('balanceId', isEqualTo: id)
        .where('currentDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('currentDate', isLessThanOrEqualTo: endTimestamp)
        .snapshots();

    return incomes;
  }
  Future<Stream<QuerySnapshot>> getBalanceById(String? id) async {
    Stream<QuerySnapshot> balance = await FirebaseFirestore.instance
        .collection('Balances')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return balance;
  }
}
