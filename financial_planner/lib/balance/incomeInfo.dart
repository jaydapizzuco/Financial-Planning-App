import 'package:financial_planner/balance/incomeModify.dart';
import 'package:flutter/material.dart';
import '../models/Income.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeInfo extends StatefulWidget {
  final String id;

  const IncomeInfo({required this.id});

  @override
  State<IncomeInfo> createState() => _IncomeInfoState();
}

class _IncomeInfoState extends State<IncomeInfo> {

  Income? income;

  @override
  void initState(){
    super.initState();

    initializeIncome();
  }

  void initializeIncome() async{
    income = await getByID(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Title',style: TextStyle(fontSize: 8)),
                  SizedBox(height: 10,),
                  Text('${income!.title}')
                ],
              )
            ),
            SizedBox(height: 20,),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                  children: [
                  Text('Amount',style: TextStyle(fontSize: 8)),
                SizedBox(height: 10,),
                Text('${income!.amount}\$')
                ],
              )
            ),
            SizedBox(height: 20,),
            Container(
              height: 100,
              width: 350,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Description',style: TextStyle(fontSize: 8)),
                  SizedBox(height: 10,),
                  Text('${income!.description}')
                ],
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyIncome(income: income)));

                }, child: Text("Modify", style: TextStyle(fontSize: 20),),
                )
            ),
            SizedBox(height: 20,),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Back to Balance", style: TextStyle(fontSize: 20),),
                )
            ),
          ],
        ),
      ),
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

}


