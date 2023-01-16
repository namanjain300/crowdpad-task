import 'package:crowdpad_task/constants/custom_scroll_behaviour.dart';
import 'package:crowdpad_task/screens/video_thumbnail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      title: 'CrowdPad Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: VideoThumbScreen(),
    );
  }
}
