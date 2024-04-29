import 'package:flutter/material.dart';
import 'addGoal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'goalInfo.dart';

class GoalScreen extends StatefulWidget {
  final String? userId;

  GoalScreen({this.userId});


  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {

  Stream<QuerySnapshot>? _goalsStream;

  int? dateNow;

  @override
  void initState() {
    super.initState();
    setDateNow();
    getGoals();
  }

  void getGoals() async {
    Stream<QuerySnapshot>? _goals = await _getGoals(widget.userId);

    setState(() {
      _goalsStream = _goals;
    });
  }

  void setDateNow(){
    DateTime now = DateTime.now();
    String dateTimeNow = '${now.year}' + '${now.month}' + '${now.day}';
    int dNow = int.parse(dateTimeNow);

    dateNow = dNow;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:  Text("Goals ${widget.userId}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
    );
  }

  Future <Stream<QuerySnapshot>> _getGoals(String? id) async {
    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .snapshots();

    return goals;
  }

  /*
  Future <Stream<QuerySnapshot>> _getGoalsInProgress(String? id) async {
    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 'inProgress')
        .snapshots();

    return goals;
  }

  Future <Stream<QuerySnapshot>> _getFutureGoals(String? id) async {

    DateTime now = DateTime.now();
    String dateNow = '${now.year}' + '${now.month}' + '${now.day}';
    int dNow = int.parse(dateNow);

    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('startDate', isGreaterThan: dNow)
        .snapshots();

    return goals;
  }



  Future <Stream<QuerySnapshot>> _getCompletedGoals(String? id) async {



    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .snapshots();

    return goals;
  }*/
}
