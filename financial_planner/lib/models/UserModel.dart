import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String? id;
  final String? username;
  final String? email;

  UserModel({this.id,this.username,this.email});

  static UserModel fromSnapshot(QueryDocumentSnapshot<Object?> snapshot){
    return UserModel(
        username: snapshot?['username'],
        email: snapshot['email'],
        id: snapshot? ['id']
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "username" : username,
      "email" : email,
      "id" : id,
    };
  }
}