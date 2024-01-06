import 'package:firebase_auth/firebase_auth.dart';

class Globals {
  static var currentUser = FirebaseAuth.instance.currentUser;
  static var currentEmail = currentUser?.email;
  static bool isUserAdmin = false;
}
