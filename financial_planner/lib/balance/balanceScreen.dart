import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/Balance.dart';


class BalanceScreen extends StatefulWidget {
  final String? userId;

  BalanceScreen({this.userId});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  num? balanceAmount;

  @override
  void initState()  {
    super.initState();
    setBalance();
  }

  void setBalance() async {
    num? amount = await getBalanceById(widget.userId);
    setState(() {
      balanceAmount = amount;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Balance"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Account Balance", style: TextStyle(fontSize: 30, color: Colors.blueGrey, fontWeight: FontWeight.bold),),
                    Text("\$\ ${balanceAmount}", style: TextStyle(fontSize: 50, color: Colors.blueGrey, fontWeight: FontWeight.bold),)
                  ],
                )
                )
          ],
        ),
      )
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
}