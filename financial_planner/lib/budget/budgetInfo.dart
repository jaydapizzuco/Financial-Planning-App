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