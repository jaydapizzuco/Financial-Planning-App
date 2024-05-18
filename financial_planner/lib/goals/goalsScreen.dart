import 'package:flutter/material.dart';
import 'addGoal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'goalInfo.dart';
import 'package:rxdart/rxdart.dart';

class GoalScreen extends StatefulWidget {
  final String? userId;

  GoalScreen({this.userId});


  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {

  Stream<QuerySnapshot>? _goalsStream;

  int? dateNow;

  @override
  void initState() {
    super.initState();
    setDateNow();
    getGoals();
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
          title: Text('Goals'),
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

                          }, child: Text('Future goals')),
                      SizedBox(height: 10,),
                      //button to see completed goals
                      ElevatedButton(
                          onPressed: () {

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
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.data != null &&
                            snapshot.data!.docs.isEmpty) {
                          return Text(
                            "Looks like you don't have Goals in progress right now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        return Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((
                                  DocumentSnapshot document) {
                                Map<String, dynamic> data = document
                                    .data()! as Map<String, dynamic>;
                                return Container(
                                    width: 200,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      children: [
                                        GestureDetector(
                                          child:
                                          Container(
                                            height: 150,
                                            width: 350,
                                            decoration: BoxDecoration(
                                                color: Colors.yellowAccent[100],
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
                                                subtitle: Text(
                                                    data['description'])),
                                          ),
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

    // Stream<QuerySnapshot> goalsStartdate = await FirebaseFirestore.instance
    //     .collection('Goals')
    //     .where('startDate', isLessThanOrEqualTo: date)
    //     .snapshots();

    // Stream<QuerySnapshot> goals = Rx.combineLatest2(goalsUser, goalsStartdate,
    //       (QuerySnapshot goalsUser, QuerySnapshot goalsStartdate) {
    //     List<DocumentSnapshot> goalsUserList = goalsUser.docs;
    //     List<DocumentSnapshot> goalsStartdateList = goalsStartdate.docs;
    //
    //     // Find the overlapping documents
    //     List<DocumentSnapshot> combined = goalsUserList.where((userIdAndStatusDoc) {
    //       return goalsStartdateList.any((startDateDoc) =>
    //       userIdAndStatusDoc.id == startDateDoc.id); // Assuming both streams have a common identifier
    //     }).toList();
    //
    //     //return QuerySnapshot(docs: overlappingDocs);
    //
    //   },
    // );

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
