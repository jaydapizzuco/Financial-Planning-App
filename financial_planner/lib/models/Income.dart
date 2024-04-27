import 'package:cloud_firestore/cloud_firestore.dart';

class Income{
  final String? id;
  final String? balanceId;
  final double? amount;

  Income({this.id,this.balanceId,this.amount});

  static Income fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Income(
      id: snapshot? ['id'],
      balanceId: snapshot?['balanceId'],
      amount: snapshot['amount'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "balanceId" : balanceId,
      "amount" : amount,
    };
  }
}