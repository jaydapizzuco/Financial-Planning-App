import 'package:cloud_firestore/cloud_firestore.dart';

class Budget{
  final String? id;
  final String? userId;
  final double? amount;
  final double? amountUsed;
  final String? name;
  final String? description;
  final int? timePeriod;
  final String? unitOfTime;
  final DateTime? endDate;

  Budget({this.id,this.userId,this.amount,this.amountUsed,this.name,this.description,this.timePeriod, this.unitOfTime,this.endDate});

  static Budget fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Budget(
      id: snapshot? ['id'],
      userId: snapshot?['userId'],
      amount: snapshot['amount'],
      amountUsed: snapshot['amountUsed'],
      name: snapshot?['name'],
      description: snapshot['description'],
      timePeriod: snapshot['timePeriod'],
      unitOfTime: snapshot['unitOfTime'],
      endDate: snapshot['endDate'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "userId" : userId,
      "amount" : amount,
      "amountUsed" : amountUsed,
      "name" : name,
      "description" : description,
      "timePeriod" : timePeriod,
      "unitOfTime" : unitOfTime,
      "endDate" :  endDate,
    };
  }
}