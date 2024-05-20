import 'package:financial_planner/goals/completedGoals.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:getwidget/getwidget.dart';
import '../notification.dart';
import 'addGoal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'futureGoals.dart';
import 'goalInfo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;

class GoalScreen extends StatefulWidget {
  final String? userId;

  GoalScreen({this.userId});


  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {

  Stream<QuerySnapshot>? _goalsStream;
  DateTime today = DateTime.now();

  int? dateNow;

  List <Color> colors = [
    Color(0xFFF06292),
    Color(0xFFFFCC80),
    Color(0xFFD0FFC9),
    Color(0xFFB76FFF)
  ];
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    setDateNow();
    getGoals();
    tz.initializeTimeZones();
  }

  void getGoals() async {
    Stream<QuerySnapshot>? _goals = await _getGoalsInProgress(widget.userId);

    setState(() {
      _goalsStream = _goals;
    });
  }

  void setDateNow(){
    DateTime now = DateTime.now();
    String dateTimeNow = '${now.year}' + '${now.month}' + '${now.day}';
    int dNow = int.parse(dateTimeNow);

    dateNow = dNow;
  }

  @override
  Widget build(BuildContext context) {
    if (_goalsStream == null || dateNow == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Goals In Progress'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //button to see future goals
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FutureGoals(
                                          userId: widget.userId,
                                        )),
                                    (route) => false);
                          }, child: Text('Future goals')),
                      SizedBox(height: 10,),
                      //button to see completed goals
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CompletedGoals(
                                          userId: widget.userId,
                                        )),
                                    (route) => false);
                          }, child: Text('Completed goals')),
                      SizedBox(height: 10,),
                      //button to see failed goals
                      ElevatedButton(
                          onPressed: () {

                          }, child: Text('Failed goals')),
                      SizedBox(height: 10,),
                    ],
                  ),
                StreamBuilder<QuerySnapshot>(
                    stream: _goalsStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot){
                      if(snapshot.data != null && snapshot.data!.docs.isEmpty){
                        return Text(
                          "Looks like you dont have Goals in progress right now",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading');
                      }

                      return Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map((DocumentSnapshot document){
                              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                              double ispercentage = double.parse((data['amountCompleted'] / data['goalAmount']).toStringAsFixed(2));
                              int perDisplay = (ispercentage * 100).toInt();
                              int totalDaysDifference = 0;
                              colorIndex++;
                              if(colorIndex == 4){
                                colorIndex = 0;
                              }

                              if(data['endDate'] != null) {
                                totalDaysDifference =  data['endDate'].toDate().difference(today).inDays;
                              }
                              if(totalDaysDifference != null && totalDaysDifference <=31){
                                NotificationService().showNotification(
                                    1,
                                    "Goal: ${data['name']}" ,
                                    "You have $totalDaysDifference days to save \$\ ${ data['goalAmount'] - data['amountCompleted'] }"
                                );
                              }

                              return Container(
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child:
                                        Container(
                                          height: 140,
                                          width: 350,
                                          decoration: BoxDecoration(
                                              color: colors[colorIndex],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: ListTile(
                                              title: Text(
                                                data['name'] +
                                                    "\n\$\ " +
                                                    (data['goalAmount'] -
                                                        data['amountCompleted'])
                                                        .toString() +
                                                    " remaining",
                                                style: TextStyle(
                                                  fontSize: 28,
                                                ),
                                              ),
                                              subtitle: GFProgressBar(
                                                percentage: ispercentage,
                                                backgroundColor : Colors.black,
                                                progressBarColor: Colors.green,
                                                lineHeight: 25,
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 5),
                                                  child: Text('${perDisplay}%', textAlign: TextAlign.end,
                                                    style: TextStyle(fontSize: 17, color: Colors.white),
                                                  ),
                                                ),
                                              )
                                                ),),
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GoalInfo(
                                                          userId: widget.userId,
                                                          goalId: data['id'],)),
                                                    (route) => false);
                                          },
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    ));
                              }).toList(),
                            )
                        );
                      })

                ]
            )
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddGoal(
                          userId: widget.userId,
                        )),
                    (route) => false);
          },
          label: Text('Add Goal'),
          icon: Icon(Icons.add),
        ),
      );
    }
  }

  Future <Stream<QuerySnapshot>> _getGoals(String? id) async {
    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .snapshots();

    return goals;
  }


  Future <Stream<QuerySnapshot>> _getGoalsInProgress(String? id) async {
    //int date = 20240518;
    DateTime date = DateTime.now();
    Timestamp timestampNow = Timestamp.fromDate(date);

    Stream<QuerySnapshot> goalsUser = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 0)
        .where('startDate', isLessThanOrEqualTo: date)
        .snapshots();

    return goalsUser;
  }

  Future <Stream<QuerySnapshot>> _getFutureGoals(String? id) async {

    DateTime now = DateTime.now();
    String dateNow = '${now.year}' + '${now.month}' + '${now.day}';
    int dNow = int.parse(dateNow);

    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('startDate', isGreaterThan: dateNow)
        .snapshots();

    return goals;
  }



  Future <Stream<QuerySnapshot>> _getCompletedGoals(String? id) async {

    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 1)
        .snapshots();

    return goals;
  }

  Future <Stream<QuerySnapshot>> _getFailedGoals(String? id) async {

    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 0)
        .where('endDate', isLessThan: dateNow)
        .snapshots();

    return goals;
  }
}
