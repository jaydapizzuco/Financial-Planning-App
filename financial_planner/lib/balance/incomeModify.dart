import 'package:flutter/material.dart';
import '../models/Income.dart';

import '../models/Balance.dart';
import '../models/FirebaseAuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifyIncome extends StatefulWidget {
  final Income? income;

  const ModifyIncome({required this.income});

  @override
  State<ModifyIncome> createState() => _ModifyIncomeState();
}

class _ModifyIncomeState extends State<ModifyIncome> {
  TextEditingController _title = TextEditingController();
  TextEditingController _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title.text = widget.income!.title ?? '';
    _desc.text = widget.income!.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              child: TextField(
                controller: _title,
                obscureText: false,
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _desc,
                obscureText: false,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.next,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 30.0),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    _updateData(widget.income!);

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Modify",
                    style: TextStyle(fontSize: 20),
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 20),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _updateData(Income inc) {
    final incomeCollection = FirebaseFirestore.instance.collection("Incomes");

    final newData = Income(
      id: inc.id,
      balanceId: inc.balanceId,
      amount: inc.amount,
      title: _title.text,
      description: _desc.text
    ).toJson();

    incomeCollection.doc(inc.id).update(newData);
  }
}
