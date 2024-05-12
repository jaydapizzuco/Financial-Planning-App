import 'package:cloud_firestore/cloud_firestore.dart';

class Spending{
  final String? id;
  final String? balanceId;
  final double? amount;
  final String? title;
  final String? description;
  final String? budgetId;
  final DateTime? currentDate;

  Spending({this.id,this.balanceId,this.amount, this.title, this.description, this.budgetId,this.currentDate});

  static Spending fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Spending(
        id: snapshot? ['id'],
        balanceId: snapshot?['balanceId'],
        amount: snapshot?['amount'],
        title : snapshot['title'],
        description:  snapshot?['description'],
        currentDate: snapshot?['currentDate']
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "balanceId" : balanceId,
      "amount" : amount,
      "title" : title,
      "description":  description,
      "budgetId" : budgetId,
      "currentDate" : currentDate
    };
  }
}