import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login/loginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Text("HomePage", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
          SizedBox(
              width: 200,
            child : ElevatedButton(onPressed: (){
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
            }, child: Text("Logout", style: TextStyle(fontSize: 24),)
            )
          )
          ]
        )
        ),
    );
  }
}
