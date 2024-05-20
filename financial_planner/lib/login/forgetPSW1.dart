import 'package:flutter/material.dart';

import '../models/FirebaseAuthService.dart';
import 'forgetPSW2.dart';
import 'loginScreen.dart';

class ForgetPSW1 extends StatefulWidget {
  const ForgetPSW1({super.key});

  @override
  State<ForgetPSW1> createState() => _ForgetPSW1State();
}

class _ForgetPSW1State extends State<ForgetPSW1> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _email = TextEditingController();

  sendPasswordResetEmail() async {

    try {
      if (_email.text != null) {
        _auth.sendPasswordResetEmail(_email.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An email has been sent to reset your password")));
        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPSW2()));
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
    Text("Forgot Password?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
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
