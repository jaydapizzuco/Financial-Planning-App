import 'package:flutter/material.dart';

import '../navigatingScreens.dart';

class BudgetInfo extends StatefulWidget {
  final String? userId;
  final String? budgetId;

  BudgetInfo({this.budgetId,this.userId});

  @override
  State<BudgetInfo> createState() => _BudgetInfoState();
}

class _BudgetInfoState extends State<BudgetInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.budgetId}"  ) ,
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
        )
      ),
    );
  }
}
