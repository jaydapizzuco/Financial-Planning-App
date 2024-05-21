import 'package:financial_planner/login/loginScreen.dart';
import 'package:financial_planner/profile/profileScreen.dart';
import 'package:flutter/material.dart';

import '../models/FirebaseAuthService.dart';
import 'updatePSW2.dart';

class updatePSW extends StatefulWidget {
  final String? userId;
  const updatePSW({required this.userId});

  @override
  State<updatePSW> createState() => _UpdatePSW1State();
}

class _UpdatePSW1State extends State<updatePSW> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _email = TextEditingController();

  sendPasswordResetEmail() async {

    try {
      if (_email.text != null) {
        _auth.sendPasswordResetEmail(_email.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An email has been sent to reset your password")));
        Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePSW2()));
      }
    }
    catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error has occured ${e}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Reset Password"),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Change Password", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child :TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText : 'Email'),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                    width: 350,
                    child : ElevatedButton(onPressed: (){
                      sendPasswordResetEmail();
                    }, child: Text("Send Email", style: TextStyle(fontSize: 20),),
                    )
                ),
                SizedBox(height: 10),
                SizedBox(
                    width: 350,
                    child : ElevatedButton(onPressed: (){
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false);
                    }, child: Text("Cancel", style: TextStyle(fontSize: 20),),
                    )
                ),
              ],
            )
        )
    );
  }
}
