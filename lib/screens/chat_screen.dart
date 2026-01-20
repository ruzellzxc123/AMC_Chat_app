import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();

  void addMessage(String text, bool isUser) {
    setState(() {
      messages.add(ChatMessage(
        text: text,
        isUserMessage: isUser,
        timestamp: DateTime.now(),
      ));
    });
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> handleSend(String text) async {
    addMessage(text, true);

    addMessage('🤖 AI Thinking...', false);

    try {
      final aiResponse = await GeminiService.sendMessage(text);
      setState(() {
        messages.removeLast();
      });
      addMessage(aiResponse, false);
    } catch (e) {
      setState(() {
        messages.removeLast();
      });
      addMessage('❌ Error: $e', false);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar background black
        elevation: 0,
        centerTitle: true, // Center the title text

        // 1. ADD THE LOGO HERE
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.bolt, color: Colors.blueAccent), // You can replace this Icon with an Image.asset
          ),
        ),

        title: Text(
          'Zell UI ✅',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        // Optional: Add a profile or settings icon on the right
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text(
                'Send message to start!',
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              controller: scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: messages[messages.length - 1 - index],
                );
              },
            ),
          ),
          InputBar(onSendMessage: handleSend),
        ],
      ),
    );
  }
}