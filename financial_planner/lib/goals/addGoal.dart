import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Goal.dart';
import '../models/FirebaseAuthService.dart';
import '../navigatingScreens.dart';

class AddGoal extends StatefulWidget {

  final String? userId;
  AddGoal({this.userId});

  @override
  State<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoal> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }


  void _addGoal(Goal goal) {
    final goalCollection = FirebaseFirestore.instance.collection("Goals");

    String id = goalCollection
        .doc()
        .id;

    final newGoal = Goal(
      id: id,
      userId: goal.userId,
      goalAmount: goal.goalAmount,
      amountCompleted: goal.amountCompleted,
      name: goal.name,
      description: goal.description,
      startDate: goal.startDate,
      endDate: goal.endDate,
      status: goal.status,
      daysReached: goal.daysReached,
    ).toJson();

    goalCollection.doc(id).set(newGoal);
  }
}
