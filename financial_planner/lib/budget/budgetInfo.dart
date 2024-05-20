import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/Balance.dart';
import '../navigatingScreens.dart';
import '../spendings/addSpending.dart';

class BudgetInfo extends StatefulWidget {
  final String? userId;
  final String? budgetId;

  BudgetInfo({this.budgetId,this.userId});

  @override
  State<BudgetInfo> createState() => _BudgetInfoState();
}

class _BudgetInfoState extends State<BudgetInfo> {
  Stream<QuerySnapshot>? _budget;

  DateTime today = DateTime.now();
  String timeLeft = "";
  num? balanceAmount;

  @override
  void initState() {
    super.initState();
    timeLeft = "";
    setBudget();
    setBalance();
  }

  void setBudget() async {
    Stream<QuerySnapshot>? correctBudget = await getBudgetById(widget.budgetId);
    setState(() {
      _budget = correctBudget;
    });
  }

  void setBalance() async {
    num? amount = await getBalanceById(widget.userId);
    setState(() {
      balanceAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        //child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<QuerySnapshot>(
        stream: _budget,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          DocumentSnapshot document = snapshot.data!.docs.first;
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          if (data['endDate'] != null) {
            DateTime endDate = data['endDate'].toDate();
            DateTime today = DateTime.now();
            int years = endDate.year - today.year;
            int months = endDate.month - today.month;
            int days = endDate.day - today.day;

            // if days difference is negative
            if (days < 0) {
              final previousMonthDate = DateTime(endDate.year, endDate.month, 0);
              days += previousMonthDate.day;
              months -= 1;
            }

            // if months difference is negative
            if (months < 0) {
              months += 12;
              years -= 1;
            }

            // past dates
            if (years < 0 || (years == 0 && months < 0)) {
              years = 0;
              months = 0;
              days = endDate.difference(today).inDays;
            }

            // Calculate weeks and days
            int totalDaysDifference = endDate.difference(today).inDays;
            int weeks = 0;
            if (years == 0 && months == 0) {
              weeks = totalDaysDifference ~/ 7;
              days = totalDaysDifference % 7;
            }

            timeLeft = "";

            if (years > 0) {
              timeLeft += "$years ${years == 1 ? 'Year' : 'Years'} ";
            }
            if (months > 0) {
              timeLeft += "$months ${months == 1 ? 'Month' : 'Months'} ";
            }
            if (weeks > 0) {
              timeLeft += "$weeks ${weeks == 1 ? 'Week' : 'Weeks'} ";
            }
            if (days > 0) {
              timeLeft += "$days ${days == 1 ? 'Day' : 'Days'} ";
            }
            if (timeLeft.isNotEmpty) {
              timeLeft += "Until Budget Resets";
            }
          }

          Map<String,double> dataMap = {
            'Remaining' : (data['amount'] - data['amountUsed']) as double,
            'Used' : data['amountUsed'] as double,

          } as Map<String, double>;

          List<Color> colors = [
            Color(0xFFB2FF59),
            Color(0xFFEF5350),
          ];

          return Expanded(
              child: Center(
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(data['description'], style: TextStyle(fontSize: 24),),
                  Container(
                    height: 80,
                    width: 350,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.lightGreenAccent[100],
                        borderRadius: BorderRadius.all(
                            Radius.circular(30))),
                      child: Text( "Starting amount: \$\ ${data['amount']} \n      \$\ " +
                          (data['amount'] -
                              data['amountUsed'])
                              .toString() +
                          " Remaining",
                        style: TextStyle(
                        fontSize: 28,
                      ),)
                  ),
                    SizedBox(height: 5,),
                    PieChart(
                      dataMap:dataMap,
                      colorList: colors,
                      chartRadius:280,
                      centerText: data['name'],
                      chartType: ChartType.ring,
                      ringStrokeWidth: 50,
                      animationDuration: Duration(seconds: 2),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValues: true,
                        //showChartValuesOutside: true,
                        showChartValuesInPercentage: true,
                        showChartValueBackground: false,
                        chartValueStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 28, color: Colors.black)
                      ),
                      legendOptions: LegendOptions(
                        showLegendsInRow: true,
                        legendPosition: LegendPosition.bottom,
                        legendTextStyle: TextStyle(fontSize: 20)
                      ),
                    ),
                    Text("$timeLeft", style: TextStyle(fontSize: 24),),
                SizedBox(height: 20,),
                    SizedBox(
                        height: 50,
                        width: 300,
                        child: ElevatedButton(onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddSpending(
                                    userId: widget.userId,
                                    balanceAmount: balanceAmount,
                                    budgetId: widget.budgetId,
                                  )),
                                  (route) => false);
                        },
                          child: Text(
                            "Add Spending", style: TextStyle(fontSize: 20),),
                        )
                    ),
                    SizedBox(
                        height: 50,
                        width: 300,
                        child: ElevatedButton(onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context, MaterialPageRoute(
                              builder: (context) =>
                                  NavigatingScreen(userId: widget.userId,page: 3,)), (
                              route) => false);
                        },
                          child: Text(
                            "Cancel", style: TextStyle(fontSize: 20),),
                        )
                    ),
                  ],
                )
            ),
          );
        })
    ])));

  }



Future<Stream<QuerySnapshot>> getBudgetById(String? id) async {
  Stream<QuerySnapshot> balance = await FirebaseFirestore.instance
      .collection('Budgets')
      .where('id', isEqualTo: widget.budgetId)
      .snapshots();

  return balance;
}
  Future<num?> getBalanceById(String? id) async {
    num? balanceAmount;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        balanceAmount = balance.amount;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return balanceAmount;
  }

}