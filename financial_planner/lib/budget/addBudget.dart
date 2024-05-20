import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/Budget.dart';
import '../models/FirebaseAuthService.dart';
import '../navigatingScreens.dart';
import '../notification.dart';
import 'package:timezone/data/latest.dart' as tz;

class AddBudget extends StatefulWidget {
  final String? userId;

  AddBudget({this.userId});


  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _timePeriodController = TextEditingController();

  String? unitOfTime = "Days";
  var unitsOfTime = [
    'Days',
    'Weeks',
    'Months',
  ];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a New Budget"),
        backgroundColor: Colors.purple[100],
      ),
      body: Expanded(
       // child: Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                decoration: InputDecoration(labelText: 'Budget Name'),
              ),
            ),
            SizedBox(height: 10,),
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
            SizedBox(height: 10,),
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
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _timePeriodController,
                    obscureText: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Time Period'),
                  ),
                ),
              SizedBox(width: 20,),
              DropdownButton(
              value: unitOfTime,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: unitsOfTime.map((String items) {
              return DropdownMenuItem(
              value: items,
              child: Text(items),
              );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  unitOfTime = newValue!;
                });
              }
            )
            ],
            ),
            SizedBox(height: 10,),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: () {
                  _addBudget(new Budget(
                    userId: widget.userId,
                    amount: double.parse(_amountController.text),
                    amountUsed: 0,
                    name: _nameController.text,
                    description: _descriptionController.text,
                    timePeriod: int.parse(_timePeriodController.text),
                    unitOfTime: unitOfTime,
                  ));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) =>
                          NavigatingScreen(userId: widget.userId, page :3)), (
                      route) => false);
                NotificationService().showNotification(
                1,
                _nameController.text,
                "${double.parse(_amountController.text)} remaining for the next ${int.parse(_timePeriodController.text)} $unitOfTime");
                },
                  child: Text("Create Budget", style: TextStyle(fontSize: 20),),
                )
            ),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) =>
                          NavigatingScreen(userId: widget.userId, page:3)), (
                      route) => false);
                }, child: Text("Cancel", style: TextStyle(fontSize: 20),),
                )
            ),
          ],
        ),
      ),
     // ),
    );
  }
  void _addBudget(Budget budget) {
    final budgetCollection = FirebaseFirestore.instance.collection("Budgets");

    String id = budgetCollection
        .doc()
        .id;

    DateTime today = DateTime.now();
    DateTime? endDate;

    switch (budget.unitOfTime) {
      case 'Days':
        endDate = today.add(Duration(days: budget.timePeriod as int));
      case 'Weeks':
        endDate = today.add(Duration(days: 7 * (budget.timePeriod as int)));
      case 'Months':
        endDate = DateTime(today.year, today.month + (budget.timePeriod as int), today.day);
      default:
        throw ArgumentError('Invalid unit of time');
    }

    final newBudget = Budget(
      id: id,
      userId: budget.userId,
      amount: budget.amount,
      amountUsed: budget.amountUsed,
      name: budget.name,
      description: budget.description,
      timePeriod: budget.timePeriod,
      unitOfTime: budget.unitOfTime,
      endDate: endDate,
    ).toJson();

    budgetCollection.doc(id).set(newBudget);
  }
}
