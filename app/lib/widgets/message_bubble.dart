import 'package:flutter/material.dart';

import '../models/message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  String _formatTime(DateTime createdAt) {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isMine ? Colors.white : AppTheme.text;
    final bubbleColor = isMine
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMine)
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
