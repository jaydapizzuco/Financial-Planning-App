import 'package:flutter/material.dart';

class SpendingScreen extends StatefulWidget {
  final String? userId;

  SpendingScreen({this.userId});


  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:  Text("Spendings ${widget.userId}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
    );
  }
}
