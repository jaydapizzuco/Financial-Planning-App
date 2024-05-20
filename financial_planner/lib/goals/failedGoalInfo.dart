import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/Goal.dart';
import '../navigatingScreens.dart';
import '../balance/addIncome1.dart';
import '../models/Balance.dart';

class FailedGoalInfo extends StatefulWidget {
  final String? userId;
  final String? goalId;
  const FailedGoalInfo({required this.userId, required this.goalId});

  @override
  State<FailedGoalInfo> createState() => _FailedGoalInfoState();
}

class _FailedGoalInfoState extends State<FailedGoalInfo> {
  Stream<QuerySnapshot>? _goal;
  DateTime today = DateTime.now();
  String daysLeft = "";
  num? balanceAmount;
  String? balanceId;

  @override
  void initState() {
    super.initState();
    daysLeft = "";
    setBudget();
    setBalance();
  }

  void setBudget() async {
    Stream<QuerySnapshot>? correctGoal = await getGoalById(widget.goalId);
    setState(() {
      _goal = correctGoal;
    });
  }

  void setBalance() async {
    num? amount = await getBalanceById(widget.userId);
    String? bal = await getBalanceIdById(widget.userId);

    setState(() {
      balanceAmount = amount;
      balanceId = bal;
    });


  }

  @override
  Widget build(BuildContext context) {
    if(_goal == null || balanceAmount == null || balanceId == null || today == null){
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }else{
      return Scaffold(
          appBar: AppBar(
            title: Text('Failed Goal'),
            backgroundColor: Colors.purple[100],
          ),
          body: SingleChildScrollView(
            child: Center(
              //child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30,),
                      StreamBuilder<QuerySnapshot>(
                          stream: _goal,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            int totalDaysDifference = 0;
                            if (snapshot.hasError) {
                              return Text('something went wrong');
                            }
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text('Loading');
                            }
                            DocumentSnapshot document = snapshot.data!.docs.first;
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                            if(data['endDate'] != null) {
                              totalDaysDifference =  data['endDate'].toDate().difference(today).inDays;
                            }

                            Map<String,double> dataMap = {
                              'Completed' : data['amountCompleted'] as double,
                              'Remaining' : (data['goalAmount'] - data['amountCompleted']) as double,
                            } as Map<String, double>;

                            List<Color> colors = [
                              Color(0xFFB2FF59),
                              Color(0xFFEF5350),
                            ];

                            return Center(
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
                                      child: Text( "Goal amount: \$\ ${data['goalAmount']} \n      \$\ " +
                                          (data['goalAmount'] -
                                              data['amountCompleted'])
                                              .toString() +
                                          " Remaining",
                                        style: TextStyle(
                                          fontSize: 28,
                                        ),)
                                  ),
                                  SizedBox(height: 50,),
                                  PieChart(
                                    dataMap:dataMap,
                                    colorList: colors,
                                    chartRadius:250,
                                    chartType: ChartType.ring,
                                    ringStrokeWidth: 80,
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
                                  SizedBox(height: 20,),
                                  SizedBox(
                                      height: 50,
                                      width: 300,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5), // <-- Radius
                                            ),
                                            backgroundColor: Colors.red[300]
                                        ),
                                        onPressed: () {
                                          Navigator.pushAndRemoveUntil(
                                              context, MaterialPageRoute(
                                              builder: (context) =>
                                                  NavigatingScreen(userId: widget.userId,page: 4,)), (
                                              route) => false);
                                        },
                                        child: Text(
                                          "Cancel", style: TextStyle(fontSize: 20, color: Colors.white),),
                                      )
                                  ),
                                  SizedBox(height: 20,),
                                ],
                              )
                              ,
                            );
                          })
                    ])),
          ));
    }

  }

  Future<Stream<QuerySnapshot>> getGoalById(String? id) async {
    Stream<QuerySnapshot> goal = await FirebaseFirestore.instance
        .collection('Goals')
        .where('id', isEqualTo: widget.goalId)
        .snapshots();

    return goal;
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

  Future<String?> getBalanceIdById(String? id) async {
    String? balId;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        balId = balance.id;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return balId;
  }
}
