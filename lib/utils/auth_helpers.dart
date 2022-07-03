import 'package:firebase_auth/firebase_auth.dart';

final firebaseAuthInstance = FirebaseAuth.instance;

String getUserId() {
  String userId = "anonymous";
  if (firebaseAuthInstance.currentUser != null) {
    userId = firebaseAuthInstance.currentUser!.uid;
  }
  return userId;
}
