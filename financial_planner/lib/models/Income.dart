import 'package:cloud_firestore/cloud_firestore.dart';

class Income{
  final String? id;
  final String? balanceId;
  final double? amount;
  final String? title;
  final String? description;
  final String? goalId;

  Income({this.id,this.balanceId,this.amount, this.title, this.description, this.goalId});

  static Income fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Income(
      id: snapshot? ['id'],
      balanceId: snapshot?['balanceId'],
      amount: snapshot?['amount'],
      title : snapshot['title'],
      description:  snapshot?['description'],
      goalId: snapshot?['goalId']
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "balanceId" : balanceId,
      "amount" : amount,
      "title" : title,
      "description":  description,
      "goalId": goalId
    };
  }


}