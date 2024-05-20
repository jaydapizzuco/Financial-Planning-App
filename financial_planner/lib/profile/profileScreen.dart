import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Balance.dart';
import '../models/UserModel.dart';

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
      completedGoals = comp;
      failedGoals = fail;
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
        body: Center(
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

                  },
                  child: Text('Change password'))
            ],
          ),
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

  bool comparePassword(String p1, String p2){

    // try {
    //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //       .collection('Users')
    //       .where('id', isEqualTo: id)
    //       .get();
    //
    //   if (querySnapshot.docs.isNotEmpty) {
    //     var userModel = UserModel.fromSnapshot(querySnapshot.docs.first);
    //     username = userModel.username;
    //   }
    // } catch (error) {
    //   print('Error getting ID: $error');
    // }

    return true;
  }

  Future<Stream<QuerySnapshot>> getBalanceById(String? id) async {
    Stream<QuerySnapshot> bal = await FirebaseFirestore.instance
        .collection('Balance')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();

    return bal;
  }

  Future<int?> getGoalsCompleted(String? id) async {

    Future<int?> number;
    Stream<QuerySnapshot> goals = await FirebaseFirestore.instance
        .collection('Goals')
        .where('userId', isEqualTo: id)
        .where('status', isEqualTo: 1)
        .snapshots();
    number = goals.length;
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
}
