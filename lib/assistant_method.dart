import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'global.dart';
import 'model/user_model.dart';

class AssistantMethods{
  static readCurrentOnlineUserInfo() async {
    currentFirebaseUser = firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentFirebaseUser!.uid)
        .get()
        .then((documentSnapshot)
    {
      if(documentSnapshot.exists){
        currentUserInfo = UserModel.fromSnapshot(documentSnapshot);
      }

      else {
        print('Document does not exist on the database');
      }
    });



  }


}