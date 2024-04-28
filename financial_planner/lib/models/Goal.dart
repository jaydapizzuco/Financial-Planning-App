import 'package:cloud_firestore/cloud_firestore.dart';

class Goal{
  final String? id;
  final String? userId;
  final double? goalAmount;
  final double? amountCompleted;
  final String? name;
  final String? description;
  final int? startYear;
  final int? startMonth;
  final int? startDay;

  final int? endYear;
  final int? endMonth;
  final int? endDay;

  Goal({this.id,this.userId,this.goalAmount,this.amountCompleted,this.name,this.description,this.startYear, this.startMonth, this.startDay, this.endYear, this.endMonth, this.endDay});

  static Goal fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return Goal(
      id: snapshot? ['id'],
      userId: snapshot?['userId'],
      goalAmount: snapshot['goalAmount'],
      amountCompleted: snapshot['amountCompleted'],
      name: snapshot?['name'],
      description: snapshot['description'],
      startYear: snapshot['startYear'],
      startMonth: snapshot['startMonth'],
      startDay: snapshot['startDay'],
      endYear: snapshot['endYear'],
      endMonth: snapshot['endMonth'],
      endDay: snapshot['endDay'],
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
      "startYear" : startYear,
      "startMonth" : startMonth,
      "startDay" : startDay,
      "endYear" : endYear,
      "endMonth" : endMonth,
      "endDay" : endDay,
    };
  }
}