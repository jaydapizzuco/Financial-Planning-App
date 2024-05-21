import 'package:financial_planner/login/loginScreen.dart';
import 'package:flutter/material.dart';


class UpdatePSW2 extends StatefulWidget {
  const UpdatePSW2({super.key});

  @override
  State<UpdatePSW2> createState() => _UpdatePSW2State();
}

class _UpdatePSW2State extends State<UpdatePSW2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Password Reset Email Sent", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  Text("Please click on the link provided in the email to change your password. Once the password has been changed you may reattempt to loginm", style: TextStyle(fontSize: 24, color: Colors.grey),),
                  SizedBox(height: 20,),
                  SizedBox(
                      width: 350,
                      child : ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: Text("Return to Login", style: TextStyle(fontSize: 20),),
                      )
                  )
                ]
            )
        )
    );
  }
}
