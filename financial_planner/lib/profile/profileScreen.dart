import 'package:financial_planner/profile/updatePSW.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Balance.dart';
import '../models/UserModel.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String? username;
  String? email;
  bool isLoading = true;
  Stream<QuerySnapshot>? _balance;
  int? completedGoals;
  int? failedGoals;


  @override
  void initState() {
    super.initState();
    setBalance();
    setUser();
    setGoals();
  }

  void setBalance() async {
    Stream<QuerySnapshot>? correctGoal = await getBalanceById(widget.userId);
    setState(() {
      _balance = correctGoal;
    });
  }

  void setUser() async {
    String? usern = await getUsernameById(widget.userId);
    String? ema = await getEmailById(widget.userId);

    setState(() {
      username = usern;
      email = ema;
    });


  }

  void setGoals() async{
    int? comp = await getGoalsCompleted(widget.userId);
    int? fail = await getGoalsFailed(widget.userId);

    setState(() {
      if (comp == null){
        completedGoals = 0;
      }else{
        completedGoals = comp;
      }
      if (fail == null){
        failedGoals = 0;
      }else{
        failedGoals = fail;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || username == null || email ==  null || _balance == null || completedGoals == null || failedGoals == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.purple[100],
        ),
        body: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 130,),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text('$username', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                              ElevatedButton(
                                  onPressed: (){

                                  },
                                  child: Icon(Icons.edit))
                            ],
                          ),

                          Row(
                            children: [
                              Text('$email', style: TextStyle(fontSize: 15),),
                              ElevatedButton(
                                  onPressed: (){

                                  },
                                  child: Icon(Icons.edit))
                            ],
                          ),
                        ],
                      )
                    ],
                  ),

                  ElevatedButton(
                      onPressed: (){
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => updatePSW(userId: widget.userId)),
                                (route) => false);
                      },
                      child: Text('Change password')),
                  SizedBox(height: 20,),

                  StreamBuilder<QuerySnapshot>(
                      stream: _balance,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot){
                        if(snapshot.data != null && snapshot.data!.docs.isEmpty){
                          return Text(
                            "Looks like you don't have any completed goals right now",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading');
                        }
                        return
                          ListView(
                            shrinkWrap: true,
                            children:
                            snapshot.data!.docs.map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 350,
                                    decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Center(child: Text('Account balance: \$${data['amount']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 22),),),
                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                    height: 40,
                                    width: 290,
                                    decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Center(child: Text('Gained this month: \$${data['gainedThisMonth']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),),),
                                  ),
                                  SizedBox(height: 10,),
                                  Container(
                                    height: 40,
                                    width: 290,
                                    decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Center(child: Text('Spent this month: \$${data['spentThisMonth']}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),),),
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                      }),
                  SizedBox(height: 50,),
                  Container(
                    height: 40,
                    width: 290,
                    decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.all(
                            Radius.circular(20))),
                    child: Center(child: Text('Completed goals: $completedGoals',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),),),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    height: 40,
                    width: 290,
                    decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.all(
                            Radius.circular(20))),
                    child: Center(child: Text('Failed goals: $failedGoals',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),),),
                  ),
                ],
              ),
            )
        ),
      );
    }else{
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Future<String?> getUsernameById(String? id) async {
    String? username;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userModel = UserModel.fromSnapshot(querySnapshot.docs.first);
        username = userModel.username;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return username;
  }

  Future<String?> getEmailById(String? id) async {
    String? email;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userModel = UserModel.fromSnapshot(querySnapshot.docs.first);
        email = userModel.email;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return email;
  }

  Future<Stream<QuerySnapshot>> getBalanceById(String? id) async {
    Stream<QuerySnapshot> balance = await FirebaseFirestore.instance
        .collection('Balances')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return balance;
  }

  Future<int?> getGoalsCompleted(String? id) async {

     Future<int?> number;
    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 1)
        .snapshots();
    number = goals.length;

    // StreamSubscription<QuerySnapshot> subscription = await FirebaseFirestore.instance
    //     .collection('Goals')
    //     .where('userId', isEqualTo: id)
    //     .where('status', isEqualTo: 1)
    //     .snapshots()
    //     .listen((QuerySnapshot snapshot) {
    //   length = snapshot.docs.length;
    //
    //   // Do something with the length here, like updating UI or further processing.
    // });

    return number;
  }

  Future<int?> getGoalsFailed(String? id) async {

    Future<int?> number;
    DateTime date = DateTime.now();

    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 0)
        .where('endDate', isLessThan: date)
        .snapshots();

    number = goals.length;
    return number;
  }

  Future<Stream<QuerySnapshot>> getBudgets(String? id) async {
    Stream<QuerySnapshot> bud = await FirebaseFirestore.instance
        .collection('Budgets')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
    return bud;
  }

  Future<num?> getBalanceAmountById(String? id) async {
    num? balanceAmount;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: widget.userId)
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
