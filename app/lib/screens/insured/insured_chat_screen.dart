import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/message_bubble.dart';

class InsuredChatScreen extends StatefulWidget {
  final String caseId;

  const InsuredChatScreen({super.key, required this.caseId});

  @override
  State<InsuredChatScreen> createState() => _InsuredChatScreenState();
}

class _InsuredChatScreenState extends State<InsuredChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final currentUser = appState.currentUser;
    final messages = appState.messagesForCase(widget.caseId);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Debe iniciar sesión para chatear.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat del caso'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(
                  message: message,
                  isMine: message.senderId == currentUser.id,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribí un mensaje...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;

                      appState.addMessage(
                        caseId: widget.caseId,
                        senderId: currentUser.id,
                        senderName: currentUser.name,
                        text: text,
                      );
                      _controller.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
