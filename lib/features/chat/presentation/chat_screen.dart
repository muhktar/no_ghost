import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatScreen extends HookConsumerWidget {
  final String matchId;
  
  const ChatScreen({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat $matchId'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 64),
            SizedBox(height: 16),
            Text('Chat Screen - Coming Soon'),
            Text('4-word minimum + 2-hour response window'),
          ],
        ),
      ),
    );
  }
}