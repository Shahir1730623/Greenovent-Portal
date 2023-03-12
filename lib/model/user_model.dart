import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? id;
  String? name;
  String? email;
  String? phone;
  String? imageUrl;
  String? userPosition;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.userPosition,
    this.imageUrl
  });

  UserModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> documentSnapshot){
    id = documentSnapshot.data()!["id"];
    name = documentSnapshot.data()!["name"];
    email = documentSnapshot.data()!["email"];
    phone = documentSnapshot.data()!["phone"];
    imageUrl = documentSnapshot.data()!["imageUrl"];
    userPosition = documentSnapshot.data()!["userType"];
  }
}