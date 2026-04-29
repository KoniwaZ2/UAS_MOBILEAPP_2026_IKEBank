import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  final Widget? customAction;
  final bool isActionOnly;
  final double? width;
  final double? height;
  final String? timestamp; // Tambahan: timestamp

  const ChatBubble({
    super.key,
    required this.text,
    required this.sender,
    required this.isMe,
    this.customAction,
    this.isActionOnly = false,
    this.width,
    this.height,
    this.timestamp, // Tambahkan di sini
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isActionOnly)
            Container(
              width: width,
              height: height,
              padding: const EdgeInsets.all(16),
              constraints: width == null
                  ? BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    )
                  : null,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
            ),

          if (customAction != null) ...[
            if (!isActionOnly) const SizedBox(height: 4),
            customAction!,
          ],

          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sender,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              if (timestamp != null && timestamp!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  timestamp!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
