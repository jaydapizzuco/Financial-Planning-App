import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String password) async{

    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }catch(e){
      print("An error occured : ${e}");
    }
    return null;
  }

  Future<User?> login(String email, String password) async{

    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }catch(e){
      print("An error occured : ${e}");
    }
    return null;
  }
  //requires a working email address
  Future<void> sendPasswordResetEmail(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }
    catch(e){
      print("An error occured : ${e}");
    }
  }

  // Future<void> modifyEmail(String email) async{
  //   try{
  //     User? u = await _auth.currentUser;
  //     _auth.u.up
  //   }
  //   catch(e){
  //     print("An error occured : ${e}");
  //   }
  // }
}