import 'package:flutter/material.dart';

class GoalInfo extends StatefulWidget {
  final String? userId;
  final String? goalId;
  const GoalInfo({required this.userId, required this.goalId});

  @override
  State<GoalInfo> createState() => _GoalInfoState();
}

class _GoalInfoState extends State<GoalInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
