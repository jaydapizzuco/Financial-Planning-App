import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login/loginScreen.dart';
import 'models/UserModel.dart';

class HomeScreen extends StatefulWidget {
final String? userId;

HomeScreen({this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState()  {
    super.initState();
    setUsername();
  }

  void setUsername() async {
    String? name = await getUsernameById(widget.userId);
    setState(() {
      username = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("HomePage",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                Text("Welcome Back ${username}",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                SizedBox(
                    width: 200,
                    child: ElevatedButton(onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) => LoginScreen()), (
                          route) => false);
                    }, child: Text("Logout", style: TextStyle(fontSize: 24),)
                    )
                )
              ]
          )
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
