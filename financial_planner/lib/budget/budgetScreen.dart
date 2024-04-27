import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  final String? userId;

  BudgetScreen({this.userId});


  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Budget ${widget.userId}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
    );
  }
}
