import 'package:flutter/material.dart';
import'package:firebase_core/firebase_core.dart';
import 'package:instagram_clone_project/firebase_options.dart';
import 'package:instagram_clone_project/lib_services/auth_service/sign_up_page.dart';

Future<void> main() async
{
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
 );
 runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    );
  }
}