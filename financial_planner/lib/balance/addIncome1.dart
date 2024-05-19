import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_planner/balance/balanceScreen.dart';
import 'package:financial_planner/navigatingScreens.dart';
import 'package:flutter/material.dart';

import '../models/Balance.dart';
import '../models/FirebaseAuthService.dart';
import '../models/Income.dart';

class AddIncome1 extends StatefulWidget {
  final String? userId;
  final String? balanceId;
  final num? balanceAmount;
  final String? goalId;
  AddIncome1({this.userId,this.balanceAmount,this.balanceId,this.goalId});

  @override
  State<AddIncome1> createState() => _AddIncome1State();
}

class _AddIncome1State extends State<AddIncome1> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? balanceId;
  Stream<QuerySnapshot>? _goalsStream;
  String? associatedGoalName;
  String? associatedGoalId;

  @override
  void initState() {
    super.initState();
    setBalance();
    getGoals();
    associatedGoalId = widget.goalId;
  }

  void setBalance() async {
    String? id = await getBalanceIdById(widget.userId);
    setState(() {
      balanceId = id;
    });
  }

  void getGoals() async {
    Stream<QuerySnapshot>? _goals = await _getGoals(widget.userId);

    setState(() {
      _goalsStream = _goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Income"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _titleController,
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Title'),
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
                height: 100,
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
              StreamBuilder<QuerySnapshot>(
                  stream: _goalsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading');
                    }

                    List<DropdownMenuItem<String>> dropdownItems = [];
                    Map<String, String> budgetNames = {};

                    snapshot.data!.docs.forEach((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<
                          String,
                          dynamic>;
                      String name = data['name'];
                      String id = data['id'];
                      budgetNames[id] = name;
                      dropdownItems.add(DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      ));
                    });
                    return DropdownButton<String>(
                      hint: Text('Select a Goal'),
                      value: associatedGoalId,
                      onChanged: (String? newValue) {
                        setState(() {
                          associatedGoalId = newValue;
                          associatedGoalName = budgetNames[newValue];
                        });
                      },
                      items: dropdownItems,
                    );
                  }),
              SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(onPressed: () {
                    DateTime now = DateTime.now();
                    DateTime currentDate = DateTime(now.year , now.month, now.day);
                    _addIncome(new Income(
                      balanceId: widget.balanceId,
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      description: _descriptionController.text,
                      currentDate: currentDate,
                    ));
                    _updateBalance(Balance(
                      id: widget.balanceId,
                      userId: widget.userId,
                      amount: widget.balanceAmount! + double.parse(_amountController.text),
                    ));
                    _updateGoal(associatedGoalId,double.parse(_amountController.text));
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) =>
                            NavigatingScreen(userId: widget.userId)), (
                        route) => false);
                  }, child: Text("Add Income", style: TextStyle(fontSize: 20),),
                  )
              ),
              SizedBox(height: 20,),
              SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) =>
                            NavigatingScreen(userId: widget.userId)), (
                        route) => false);
                  }, child: Text("Cancel", style: TextStyle(fontSize: 20),),
                  )
              ),
            ],
          ),
        ),
      )

    );
  }

  void _addIncome(Income income) {
    final incomeCollection = FirebaseFirestore.instance.collection("Incomes");

    String id = incomeCollection
        .doc()
        .id;

    final newIncome = Income(
        id: id,
        balanceId: income.balanceId,
        amount: income.amount,
        title: income.title,
        description: income.description,
        currentDate: income.currentDate
    ).toJson();

    incomeCollection.doc(id).set(newIncome);
  }

  Future<String?> getBalanceIdById(String? id) async {
    String? balanceId;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        balanceId = balance.id;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return balanceId;
  }

  Future<Stream<QuerySnapshot>> _getGoals(String? id) async {
    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return goals;
  }

  void _updateGoal(String? goalId, num income) async {
    DocumentReference budget = FirebaseFirestore.instance.collection('Goals')
        .doc(goalId);
    try {
      DocumentSnapshot snapshot = await budget.get();
      if (snapshot.exists) {
        num currentAmountComp = snapshot['amountCompleted'];
        num newAmountComp = currentAmountComp + income;
        await budget.update({
          'amountCompleted': newAmountComp,
        });
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

//after an income has been added we need to add this amount to out balance
  void _updateBalance(Balance balance) {
    final balanceCollection = FirebaseFirestore.instance.collection("Balances");

    final updatedBalance = Balance(
        id: balance.id,
        userId: balance.userId,
        amount: balance.amount
    ).toJson();

    balanceCollection.doc(balance.id).update(updatedBalance);
  }
}