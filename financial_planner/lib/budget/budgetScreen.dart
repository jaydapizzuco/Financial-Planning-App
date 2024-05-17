import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addBudget.dart';

class BudgetScreen extends StatefulWidget {
  final String? userId;

  BudgetScreen({this.userId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  Stream<QuerySnapshot>? _budgetStream;

  @override
  void initState() {
    super.initState();
    getBudgets();
  }

  void getBudgets() async {
    Stream<QuerySnapshot>? _budgets = await _getBudgets(widget.userId);

    setState(() {
      _budgetStream = _budgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Budgets"),
        ),
        body: Center(
            //child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              StreamBuilder<QuerySnapshot>(
                  stream: _budgetStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading');
                    }
                    return Expanded(
                        child: ListView(
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Container(
                            width: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // GestureDetector(
                                //    child:
                                Container(
                                  height: 150,
                                  width: 350,
                                  decoration: BoxDecoration(
                                      color: Colors.yellowAccent[100],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: ListTile(
                                      title: Text(
                                        data['name'] +
                                            "\n\$\ " +
                                            (data['amount'] -
                                                    data['amountUsed'])
                                                .toString() +
                                            " remaining",
                                        style: TextStyle(
                                          fontSize: 28,
                                        ),
                                      ),
                                      subtitle: Text(data['description'])),
                                ),
                                SizedBox(height: 20,)
                                //   onTap: (){
                                //     Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeInfo(id: data['id'])));
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       const SnackBar(
                                //         content: Text('A SnackBar has been shown.'),
                                //       ),
                                //     );
                                //   },
                                // ),
                              ],
                            ));
                      }).toList(),
                    ));
                  }),
            ]
            )
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AddBudget(
                    userId: widget.userId,
                  )),
                  (route) => false);
        },
        label: Text('Add Budget'),
        icon: Icon(Icons.add),
      ),
    );
  }

  Future<Stream<QuerySnapshot>> _getBudgets(String? id) async {
    Stream<QuerySnapshot> budgets = await FirebaseFirestore.instance
        .collection('Budgets')
        .where('userId', isEqualTo: id)
        .snapshots();

    return budgets;
  }
}
