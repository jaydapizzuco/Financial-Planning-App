import 'package:financial_planner/goals/completedGoalInfo.dart';
import 'package:financial_planner/navigatingScreens.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:getwidget/getwidget.dart';
import 'addGoal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'futureGoalInfo.dart';
import 'goalInfo.dart';
import 'package:rxdart/rxdart.dart';

class CompletedGoals extends StatefulWidget {
  final String? userId;

  CompletedGoals({this.userId});


  @override
  State<CompletedGoals> createState() => _CompletedGoalsState();
}

class _CompletedGoalsState extends State<CompletedGoals> {

  Stream<QuerySnapshot>? _goalsStream;

  int? dateNow;

  @override
  void initState() {
    super.initState();
    setDateNow();
    getGoals();
  }

  void getGoals() async {
    Stream<QuerySnapshot>? _goals = await _getCompletedGoals(widget.userId);


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
          title: Text('Future Goals'),
          backgroundColor: Colors.purple[100],
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NavigatingScreen(
                                          userId: widget.userId,
                                          page: 4,)),
                                    (route) => false);

                          }, child: Text('Goals In Progress')),
                    ],
                  ),
                  SizedBox(height: 20,),
                  StreamBuilder<QuerySnapshot>(
                      stream: _goalsStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot){
                        if(snapshot.data != null && snapshot.data!.docs.isEmpty){
                          return Text(
                            "Looks like you don't have any completed goals right now",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          );
                        }
                        if (snapshot.hasError) {
                          print("$snapshot.error");
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
                                                color: Colors.green[200],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
                                            child: ListTile(
                                                title: Text(
                                                  data['name'] +
                                                      "\n\$\ " +
                                                      (data['goalAmount']).toString(),
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                  ),
                                                ),
                                                subtitle: GFProgressBar(
                                                  percentage: 1,
                                                  backgroundColor : Colors.black,
                                                  progressBarColor: Colors.green,
                                                  lineHeight: 25,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: 5),
                                                    child: Text('100%', textAlign: TextAlign.end,
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
                                                        CompletedGoalInfo(
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

  Future <Stream<QuerySnapshot>> _getCompletedGoals(String? id) async {

    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 1)
        .snapshots();

    return goals;
  }
}
