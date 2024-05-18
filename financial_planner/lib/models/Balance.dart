import 'package:cloud_firestore/cloud_firestore.dart';

class Balance{
  final String? id;
  final String? userId;
  final double? amount;
  final double? spentThisMonth;
  final double? gainedThisMonth;

  Balance({this.id,this.userId,this.amount, this.spentThisMonth, this.gainedThisMonth});

  static Balance fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Balance(
      id: snapshot? ['id'],
      userId: snapshot?['userId'],
      amount: snapshot['amount'],
      spentThisMonth: snapshot['spentThisMonth'],
      gainedThisMonth: snapshot['gainedThisMonth'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "userId" : userId,
      "amount" : amount,
      "spentThisMonth" :spentThisMonth,
      "gainedThisMonth" : gainedThisMonth,
    };
  }
}