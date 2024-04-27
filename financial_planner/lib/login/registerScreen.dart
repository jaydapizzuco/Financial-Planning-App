import 'package:financial_planner/FirebaseAuthService.dart';
import 'package:financial_planner/login/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:financial_planner/homeScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _register() async {
  String username = _usernameController.text;
  String email = _emailController.text;
  String password = _passwordController.text;

  var user = await _auth.register(email, password);
  if(user != null){
    print("User has been successfully created");
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }else{
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your password must be at least 6 characters.")));
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
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
                    controller: _usernameController,
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(labelText : 'Username'),
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
                        _register();
                    }, child: Text("Register", style: TextStyle(fontSize: 20),),
                    )
                ),SizedBox(height: 10,),
                Row(
                  children: [
                    Text("Already have an account?"),
                    SizedBox(width: 5,),
                    GestureDetector(
                      onTap:(){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginScreen()), (route) => false);
                      },
                      child: Text('Sign In', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),),
                    )
                  ],
                )
              ],
            )
        )
    );
  }
}
