 import 'package:flutter/material.dart';
import 'package:myapp/notes.dart';
import 'package:firebase_core/firebase_core.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
  apiKey: "AIzaSyCgQ7K005nd_yyKbP0ChoNxAO4bBtLj4Rk",
  appId: "1:928547270425:android:1ad7506ccf56f14ccfdf88",
  messagingSenderId: "928547270425",
  projectId: "act5-b1d30",
),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Note());
  }
}