import 'package:financial_planner/balance/balanceScreen.dart';
import 'package:financial_planner/budget/budgetScreen.dart';
import 'package:financial_planner/goals/goalsScreen.dart';
import 'package:financial_planner/homeScreen.dart';
import 'package:financial_planner/spendings/spendingsScreen.dart';
import 'package:flutter/material.dart';

import 'login/loginScreen.dart';


class NavigatingScreen extends StatefulWidget {
  final String? userId;
  final int? page;
  NavigatingScreen({super.key, required this.userId, this.page});

  @override
  State<NavigatingScreen> createState() => _NavigatingScreenState();
}

class _NavigatingScreenState extends State<NavigatingScreen> {
  int currentPage = 0;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = (widget.page != null ? widget.page : 0)!;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          indicatorColor: Colors.purple[100],
          selectedIndex: currentPage,
          destinations: const <Widget>[
            NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home'
            ),

            NavigationDestination(
                icon: Icon(Icons.attach_money),
                label: 'Balance'
            ),

            NavigationDestination(
                icon: Icon(Icons.money_off),
                label: 'Spendings'
            ),

            NavigationDestination(
                icon: Icon(Icons.money),
                label: 'Budgets'
            ),

            NavigationDestination(
                icon: Icon(Icons.work_history),
                label: 'Goals'
            ),
          ],
        ),

        body: <Widget>[

          //add all the screens
          HomeScreen(userId: widget.userId),

          BalanceScreen(userId: widget.userId),

          SpendingScreen(userId: widget.userId),

          BudgetScreen(userId: widget.userId),

          GoalScreen(userId: widget.userId),

        ][currentPage],
      ),
    );
  }
}

