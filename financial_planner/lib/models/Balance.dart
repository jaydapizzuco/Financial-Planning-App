import 'package:cloud_firestore/cloud_firestore.dart';

class Balance{
  final String? id;
  final String? userId;
  final double? amount;

  Balance({this.id,this.userId,this.amount});

  static Balance fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Balance(
      id: snapshot? ['id'],
      userId: snapshot?['userId'],
      amount: snapshot['amount'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "userId" : userId,
      "amount" : amount,
    };
  }
}