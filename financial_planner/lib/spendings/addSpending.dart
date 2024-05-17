import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_planner/navigatingScreens.dart';

import '../models/Balance.dart';
import '../models/Budget.dart';
import '../models/Spending.dart';
import '../models/FirebaseAuthService.dart';


class AddSpending extends StatefulWidget {

  final String? userId;
  final num? balanceAmount;
  const AddSpending({required this.userId, required this.balanceAmount});

  @override
  State<AddSpending> createState() => _AddSpendingState();
}

class _AddSpendingState extends State<AddSpending> {

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? balanceId;
  Stream<QuerySnapshot>? _budgetStream;
  String? associatedBudgetName;

  String? associatedBudgetId;

  @override
  void initState() {
    super.initState();
    setBalance();
    getBudgets();
  }

  void setBalance() async {
    String? id = await getBalanceIdById(widget.userId);
    setState(() {
      balanceId = id;
    });
  }

  void getBudgets() async {
    Stream<QuerySnapshot>? _budgets = await _getBudgets(widget.userId);

    setState(() {
      _budgetStream = _budgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Spending"),
      ),
      body:  Expanded(
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
                stream: _budgetStream,
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
                    hint: Text('Select a Budget'),
                    value: associatedBudgetId,
                    onChanged: (String? newValue) {
                      setState(() {
                        associatedBudgetId = newValue;
                        associatedBudgetName = budgetNames[newValue];
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
                  DateTime currentDate = DateTime(now.year, now.month, now.day);
                  _addSpending(new Spending(
                    balanceId: balanceId,
                    title: _titleController.text,
                    amount: double.parse(_amountController.text),
                    description: _descriptionController.text,
                    budgetId: associatedBudgetId,
                    currentDate: currentDate,
                  ));
                  _updateBalance(Balance(
                    id: balanceId,
                    userId: widget.userId,
                    amount: widget.balanceAmount! -
                        double.parse(_amountController.text),
                  ));
                  _updateBudget(associatedBudgetId,double.parse(_amountController.text));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) =>
                          NavigatingScreen(userId: widget.userId)), (
                      route) => false);
                }, child: Text("Add Spending", style: TextStyle(fontSize: 20),),
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
      ),
    );
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

  Future<Stream<QuerySnapshot>> _getBudgets(String? id) async {
    Stream<QuerySnapshot> budgets = await FirebaseFirestore.instance
        .collection('Budgets')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return budgets;
  }

  void _addSpending(Spending spending) {
    final spendingCollection = FirebaseFirestore.instance.collection(
        "Spendings");

    String id = spendingCollection
        .doc()
        .id;

    final newSpending = Spending(
        id: id,
        balanceId: spending.balanceId,
        amount: spending.amount,
        title: spending.title,
        description: spending.description,
        currentDate: spending.currentDate,
        budgetId: spending.budgetId
    ).toJson();

    spendingCollection.doc(id).set(newSpending);
  }

  void _updateBalance(Balance balance) {
    final balanceCollection = FirebaseFirestore.instance.collection("Balances");

    final updatedBalance = Balance(
        id: balance.id,
        userId: balance.userId,
        amount: balance.amount
    ).toJson();

    balanceCollection.doc(balance.id).update(updatedBalance);
  }

  void _updateBudget(String? budgetId, num spending) async {
    DocumentReference budget = FirebaseFirestore.instance.collection('Budgets')
        .doc(budgetId);
    try {
      DocumentSnapshot snapshot = await budget.get();
      if (snapshot.exists) {
        num currentAmountUsed = snapshot['amountUsed'];
        num newAmountUsed = currentAmountUsed + spending;
        await budget.update({
          'amountUsed': newAmountUsed,
        });
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

}