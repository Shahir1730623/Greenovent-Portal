import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? id;
  String? name;
  String? email;
  String? phone;
  String? userType;
  String? userPosition;

  UserModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> documentSnapshot){
    id = documentSnapshot.get('id');
    name = documentSnapshot.get('name');
    email = documentSnapshot.get('email');
    phone = documentSnapshot.get('phone');
    userType = documentSnapshot.get('userType');
    userPosition = documentSnapshot.get('userPosition');
  }
}