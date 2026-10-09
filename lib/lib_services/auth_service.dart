import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // 1. Sign Up
  Future<String> signUp({
    required String email,
    required String password,
    required String username,
  }) async
  {
    try
    {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password);
      String uid = userCredential.user!.uid;

      _firestore.collection("users").doc(uid).set({
        "email": email,
        "uid": uid,
        "username": username,
        "followers": 0,
        "following": 0,
        "posts": 0,
        "profilephoto": "",
      });
      return "success";
    }
    on FirebaseAuthException catch(e)
    {
      print(e.code);
      return e.code;
    }
  }
  // 1. Sign In
  Future<String> signIn({
    required String email,
    required String password,
  }) async
  {
    try
    {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    }
    on FirebaseAuthException catch(e)
    {
      print(e.code);
      return e.code;
    }
  }
}