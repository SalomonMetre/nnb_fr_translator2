import 'package:firebase_auth/firebase_auth.dart';
import 'package:nnb_fr_translator2/utilities/globals.dart';

class Auth {
  final FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;
  static final instance = Auth._();
  Auth._();
  factory Auth() {
    return instance;
  }

  Future<UserCredential> registerUser(
      {required String email, required String password}) async {
    return await firebaseAuthInstance.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> sendVerificationEmail() async {
    await Globals.currentUser?.sendEmailVerification();
  }

  Future<UserCredential> loginUser(
      {required String email, required String password}) async {
    return await firebaseAuthInstance.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await firebaseAuthInstance.signOut();
  }
}
