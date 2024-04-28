import 'package:cloud_firestore/cloud_firestore.dart';

class Budget{
  final String? id;
  final String? userId;
  final double? amount;
  final String? name;
  final String? description;
  final int? timePeriod;
  final String? unitOfTime;

  Budget({this.id,this.userId,this.amount,this.name,this.description,this.timePeriod, this.unitOfTime});

  static Budget fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Budget(
      id: snapshot? ['id'],
      userId: snapshot?['userId'],
      amount: snapshot['amount'],
      name: snapshot?['name'],
      description: snapshot['description'],
      timePeriod: snapshot['timePeriod'],
      unitOfTime: snapshot['unitOfTime'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "userId" : userId,
      "amount" : amount,
      "name" : name,
      "description" : description,
      "timePeriod" : timePeriod,
      "unitOfTime" : unitOfTime,
    };
  }
}