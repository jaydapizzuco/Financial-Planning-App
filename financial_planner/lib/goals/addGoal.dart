import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Goal.dart';
import '../models/FirebaseAuthService.dart';
import '../navigatingScreens.dart';
import 'package:intl/intl.dart';
import 'package:getwidget/getwidget.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../notification.dart';

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

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  Future<void> _selectStart(BuildContext context) async{
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime(2030));
    if(pickedDate != null && pickedDate != startDate){
      setState(() {
        startDate =pickedDate;
      });
    }
  }

  Future<void> _selectEnd(BuildContext context) async{
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: endDate,
        firstDate: endDate,
        lastDate: DateTime(2030));
    if(pickedDate != null && pickedDate != endDate){
      setState(() {
        endDate =pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a New Goal"),
        backgroundColor: Colors.purple[100],
      ),
      body: SingleChildScrollView(
        // child: Center(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText: 'Goal Name'),
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
                  height: 70,
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
                ElevatedButton(onPressed: (){
                  _selectStart(context);
                }, child: Text('Start date: ${DateFormat('yyyy-MM-dd').format(startDate)}')),
                SizedBox(height: 20,),
                ElevatedButton(onPressed: (){
                  _selectEnd(context);
                }, child: Text('End date: ${DateFormat('yyyy-MM-dd').format(endDate)}')),
                SizedBox(height: 20,),
                SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(onPressed: () {
                      _addGoal(new Goal(
                        userId: widget.userId,
                        goalAmount: double.parse(_amountController.text),
                        amountCompleted: 0,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        startDate: startDate,
                        endDate: endDate,
                        status: 0,
                        daysReached: 0,
                      ));
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) =>
                              NavigatingScreen(userId: widget.userId, page: 4,)), (
                          route) => false);
                      NotificationService().showNotification(
                          1,
                          _nameController.text,
                          "Save ${double.parse(_amountController.text)} between $startDate and $endDate");
                    },
                      child: Text("Create Goal", style: TextStyle(fontSize: 20),),
                    )
                ),
                SizedBox(height: 10,),
                SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(onPressed: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) =>
                              NavigatingScreen(userId: widget.userId, page: 4)), (
                          route) => false);
                    }, child: Text("Cancel", style: TextStyle(fontSize: 20),),
                    )
                ),
              ],
            )
        ),
      ),
      // ),
    );
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
