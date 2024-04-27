import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finances'),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              //ListView for notifications
              ListView(),

              SizedBox(height: 20,),

              //Container for the tree
              Container(
                height: 400,
                width: 300,
                color: Colors.grey,
              ),

              SizedBox(height: 20,),

              //Container for the account balance
              Container(
                width: 300,
                height: 50,
                child: Text('Account balance: '),
              )

            ],
          ),

          //need to add a menu as well 
        ),
      ),
    );
  }
}
