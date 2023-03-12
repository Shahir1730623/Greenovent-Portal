import 'package:firebase_auth/firebase_auth.dart';
import 'package:greenovent_portal/model/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? currentUserInfo;
String? loggedInUser;
