import 'package:financial_planner/balance/incomeModify.dart';
import 'package:flutter/material.dart';
import '../models/Income.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navigatingScreens.dart';

class IncomeInfo extends StatefulWidget {
  final String incomeId;
  final String? userId;

  const IncomeInfo({required this.incomeId, required this.userId});

  @override
  State<IncomeInfo> createState() => _IncomeInfoState();
}

class _IncomeInfoState extends State<IncomeInfo> {

  Stream<QuerySnapshot>? _income;

  @override
  void initState(){
    super.initState();

    setIncome();
  }

  void setIncome() async {
    Stream<QuerySnapshot>? correctIn = await getIncomeById(widget.incomeId);
    setState(() {
      _income = correctIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: _income,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot){
                    if (snapshot.hasError) {
                      return Text('something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading');
                    }
                    DocumentSnapshot document = snapshot.data!.docs.first;
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                    return Center(
                      child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(data['title'], style: TextStyle(fontSize: 24),),
                          Text(data['description'], style: TextStyle(fontSize: 24),),
                          Text('${data['amount']}\$', style: TextStyle(fontSize: 24),),
                          
                          SizedBox(height: 20,),
                          SizedBox(
                              height: 50,
                              width: 300,
                              child: ElevatedButton(onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context, MaterialPageRoute(
                                    builder: (context) =>
                                        NavigatingScreen(userId: widget.userId)), (
                                    route) => false);
                              },
                                child: Text(
                                  "Cancel", style: TextStyle(fontSize: 20),),
                              )
                          ),
                          SizedBox(height: 20,),
                        ],
                      )
                      ,
                    );
                  }
              )
            ],
          ),
        ),
      )

    );
  }

  Future<Income?> getByID(String id) async{
    Income? inc;

    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Incomes')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var income = Income.fromSnapshot(querySnapshot.docs.first);
        inc = income;
      }

    }catch(error){
      print('Error getting id: ${id}');
    }

    return inc;
  }

  Future<Stream<QuerySnapshot>> getIncomeById(String? id) async {
    Stream<QuerySnapshot> income = await FirebaseFirestore.instance
        .collection('Incomes')
        .where('id', isEqualTo: widget.incomeId)
        .snapshots();

    return income;
  }

}


