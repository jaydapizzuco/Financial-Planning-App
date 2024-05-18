import 'package:cloud_firestore/cloud_firestore.dart';

class Goal{
  final String? id;
  final String? userId;
  final double? goalAmount;
  final double? amountCompleted;
  final String? name;
  final String? description;
  final int? startDate;
  final int? endDate;
  final int? status;
  final int? daysReached;

  Goal({this.id,this.userId,this.goalAmount,this.amountCompleted,this.name,this.description,this.startDate, this.endDate, this.status, this.daysReached});

  static Goal fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Goal(
      id: snapshot? ['id'],
      userId: snapshot?['userId'],
      goalAmount: snapshot['goalAmount'],
      amountCompleted: snapshot['amountCompleted'],
      name: snapshot?['name'],
      description: snapshot['description'],
      startDate: snapshot['startDate'],
      endDate: snapshot['endDate'],
      status: snapshot['status'],
      daysReached: snapshot['daysReached']
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "id" : id,
      "userId" : userId,
      "goalAmount" : goalAmount,
      "amountCompleted" : amountCompleted,
      "name" : name,
      "description" : description,
      "startDate" : startDate,
      "endDate" : endDate,
      "status" : status,
      "daysReached" : daysReached
    };
  }
}