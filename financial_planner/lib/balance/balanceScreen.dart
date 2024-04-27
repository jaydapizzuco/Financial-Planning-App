import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class BalanceScreen extends StatefulWidget {
  final String? userId;

  BalanceScreen({this.userId});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:  Text(" Balance Screen ${widget.userId}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
    );
  }
}
