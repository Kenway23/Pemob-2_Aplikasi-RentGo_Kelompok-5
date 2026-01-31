import 'package:flutter/material.dart';

class ChatRenter extends StatelessWidget {
  const ChatRenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('Chat Customer')),
    );
  }
}