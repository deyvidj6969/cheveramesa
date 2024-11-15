import 'package:engineering/funtions/funtions.dart';
import 'package:engineering/models/Chats.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final Messagefirebase message;
  final bool isMe;
  final bool showDateLabel;

  const MessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.showDateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDateLabel)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              formatDateLabel(message.tiempo),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFF2404E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                formatTime(message.tiempo),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
