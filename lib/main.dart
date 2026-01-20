import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';  // ← Points to FULL chat screen

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return // In main.dart
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark, // This makes default text white
          scaffoldBackgroundColor: Colors.black,
        ),
        home: ChatScreen(),
      );
  }
}