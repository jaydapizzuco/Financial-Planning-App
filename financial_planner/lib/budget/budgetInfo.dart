import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../navigatingScreens.dart';

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
  int? remainingTime;
  String? timeLeft = "";
  String? timeUnit;
  int? yearsRemaining = 0;
  int? monthsRemaining = 0;
  int? weeksRemaining = 0;
  int? daysRemaining = 0;

  @override
  void initState() {
    super.initState();
    setBudget();
  }

  void setBudget() async {
    Stream<QuerySnapshot>? correctBudget = await getBudgetById(widget.budgetId);
    setState(() {
      _budget = correctBudget;
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
            return Text('Loading');
          }
          DocumentSnapshot document = snapshot.data!.docs.first;
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

          if(data['endDate'] != null) {

            int years = data['endDate'].toDate().year - today.year;
            int months = data['endDate'].toDate().month - today.month;
            int days = data['endDate'].toDate().day - today.day;

            if (days < 0) {
              final previousMonthDate = DateTime(data['endDate'].toDate().year, data['endDate'].toDate().month, 0);
              days += previousMonthDate.day;
              months -= 1;
            }

            if (months < 0) {
              months += 12;
              years -= 1;
            }

            if (years < 0) {
              months = 0;
              days = data['endDate'].toDate().difference(today).inDays;
              years = 0;
            }

            int totalDaysDifference = data['endDate'].toDate().difference(today).inDays;
            int totalWeeks = totalDaysDifference ~/ 7;
            int weeks = totalWeeks % 4;
            days = totalDaysDifference % 7;

            if(years > 0){
              if(years == 1){
                timeLeft = "$years Year";
              }
              else {
                timeLeft = "$years Years";
              }
            }
            if(months > 0){
              if(months == 1){
                timeLeft = "$timeLeft $months Month";
              }
              else {
                timeLeft = "$timeLeft $months Months";
              }
            }
            if(weeks > 0) {
              if(weeks == 1){
                timeLeft = "$timeLeft $weeks Week";
              }
              else {
                timeLeft = "$timeLeft $weeks Weeks";
              }
            }
            if(days > 0) {
              if (days == 1) {
                timeLeft = "$timeLeft $days Day";
              }
              else {
                timeLeft = "$timeLeft $days Days";
              }
            }
            timeLeft = "$timeLeft Until Budget Resets";

            //
            // switch (data['unitOfTime']) {
            //   case 'Days':
            //     remainingTime = data['endDate']
            //         .toDate()
            //         .difference(today)
            //         .inDays;
            //   case 'Weeks':
            //     remainingTime = data['endDate']
            //         .toDate()
            //         .difference(today)
            //         .inDays ~/ 7;
            //   case 'Months':
            //     int yearDiff = data['endDate']
            //         .toDate()
            //         .year - today.year;
            //     int monthDiff = data['endDate']
            //         .toDate()
            //         .month - today.month;
            //     remainingTime = yearDiff * 12 + monthDiff;
            //   default:
            //     throw ArgumentError('Invalid unit of time');
            // }

            //
            // if (remainingTime == 1) {
            //   timeUnit =
            //       data['unitOfTime'].toString().substring(0, data['unitOfTime']
            //           .toString()
            //           .length - 1);
            // }
            // else {
            //   timeUnit = data['unitOfTime'];
            // }
            //
            //
            // timeLeft = "$remainingTime  $timeUnit until budget resets";
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
                      child: Text( "\$\ " +
                          (data['amount'] -
                              data['amountUsed'])
                              .toString() +
                          " Remaining",
                        style: TextStyle(
                        fontSize: 28,
                      ),)
                  ),
                    PieChart(
                      dataMap:dataMap,
                      colorList: colors,
                      chartRadius:330,
                      centerText: data['name'],
                      chartType: ChartType.ring,
                      ringStrokeWidth: 50,
                      animationDuration: Duration(seconds: 2),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValues: true,
                        showChartValuesOutside: true,
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
                              context, MaterialPageRoute(
                              builder: (context) =>
                                  NavigatingScreen(userId: widget.userId)), (
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

}