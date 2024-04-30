import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_planner/balance/balanceScreen.dart';
import 'package:financial_planner/navigatingScreens.dart';
import 'package:flutter/material.dart';

import '../models/Balance.dart';
import '../models/FirebaseAuthService.dart';
import '../models/Income.dart';

class AddIncome1 extends StatefulWidget {
  final String? userId;
  final String? balanceId;
  final num? balanceAmount;
  AddIncome1({this.userId,this.balanceAmount,this.balanceId});

  @override
  State<AddIncome1> createState() => _AddIncome1State();
}

class _AddIncome1State extends State<AddIncome1> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? balanceId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Income"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${widget.balanceAmount}'),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _titleController,
                obscureText: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _amountController,
                obscureText: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              height: 100,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: _descriptionController,
                obscureText: false,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.next,
                maxLines: null,
                decoration: InputDecoration(labelText: 'Description',
                  contentPadding: EdgeInsets.symmetric(vertical: 30.0),),
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: () {
                  _addIncome(new Income(
                    balanceId: widget.balanceId,
                    title: _titleController.text,
                    amount: double.parse(_amountController.text),
                    description: _descriptionController.text,
                  ));
                  _updateBalance(Balance(
                    id: widget.balanceId,
                    userId: widget.userId,
                    amount: widget.balanceAmount! + double.parse(_amountController.text),
                  ));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) =>
                          NavigatingScreen(userId: widget.userId)), (
                      route) => false);
                }, child: Text("Add Income", style: TextStyle(fontSize: 20),),
                )
            ),
            SizedBox(height: 20,),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) =>
                          NavigatingScreen(userId: widget.userId)), (
                      route) => false);
                }, child: Text("Cancel", style: TextStyle(fontSize: 20),),
                )
            ),
          ],
        ),
      ),
    );
  }

  void _addIncome(Income income) {
    final incomeCollection = FirebaseFirestore.instance.collection("Incomes");

    String id = incomeCollection
        .doc()
        .id;

    final newIncome = Income(
        id: id,
        balanceId: income.balanceId,
        amount: income.amount,
        title: income.title,
        description: income.description
    ).toJson();

    incomeCollection.doc(id).set(newIncome);
  }

//after an income has been added we need to add this amount to out balance
  void _updateBalance(Balance balance) {
    final balanceCollection = FirebaseFirestore.instance.collection("Balances");

    final updatedBalance = Balance(
        id: balance.id,
        userId: balance.userId,
        amount: balance.amount
    ).toJson();

    balanceCollection.doc(balance.id).update(updatedBalance);
  }
}