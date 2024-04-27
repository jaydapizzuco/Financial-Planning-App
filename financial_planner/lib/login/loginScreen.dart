import 'package:financial_planner/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:financial_planner/homeScreen.dart';
import 'registerScreen.dart';
import 'package:financial_planner/FirebaseAuthService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    var user = await _auth.login(email, password);
    if(user != null){
      print("User has been successfully signed in");
      Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You email or password is invalid. Please try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Financial App", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child :TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText : 'Email'),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child :TextFormField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText : 'Password'),
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(
              width: 350,
             child : ElevatedButton(onPressed: (){
               _login();
               }, child: Text("Login", style: TextStyle(fontSize: 20),),
            )
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Text("Don't have an account?"),
                SizedBox(width: 5,),
                GestureDetector(
                  onTap:(){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> RegisterScreen()), (route) => false);
                  },
                  child: Text('Register Now', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),),
                )
              ],
            )
          ],
        )
        )
    );
  }
}
