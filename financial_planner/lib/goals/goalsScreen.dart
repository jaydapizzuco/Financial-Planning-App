import 'package:flutter/material.dart';

class GoalScreen extends StatefulWidget {
  final String? userId;

  GoalScreen({this.userId});


  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:  Text("Goals ${widget.userId}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
    );
  }
}
