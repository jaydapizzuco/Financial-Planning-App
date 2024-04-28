import 'package:flutter/material.dart';

import 'addBudget.dart';

class BudgetScreen extends StatefulWidget {
  final String? userId;

  BudgetScreen({this.userId});


  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text("Budgets"),
    ),
    body: Center(
    //child: SingleChildScrollView(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(height: 10,),
      SizedBox(
          height: 50,
          width: 300,
          child: ElevatedButton(onPressed: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) =>
                    AddBudget(userId: widget.userId,)), (
                route) => false);
          }, child: Text("Create New Budget", style: TextStyle(fontSize: 20),),
          )
      ),
      ])
    )
    );
  }

}
