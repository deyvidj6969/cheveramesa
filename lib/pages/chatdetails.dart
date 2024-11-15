import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatName;
  final List<Map<String, dynamic>> messages;
  final String restaurantImage;

  ChatDetailPage({
    required this.chatName,
    required this.messages,
    required this.restaurantImage,
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        widget.messages.add({
          'text': text,
          'isSent': true,
          'time': 'Ahora', // Ajusta la hora actual si es necesario
        });
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.chatName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFF2404E),
        iconTheme: IconThemeData(
            color: Colors.white), // Color blanco para la flecha de retroceso
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                final isSent = message['isSent'];
                return Row(
                  mainAxisAlignment:
                      isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isSent) ...[
                      CircleAvatar(
                        backgroundImage: AssetImage(widget.restaurantImage),
                        radius: 20,
                      ),
                      SizedBox(width: 8),
                    ],
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 6.0),
                      padding: EdgeInsets.all(16.0),
                      constraints: BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isSent ? Color(0xFFF2404E) : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0),
                          bottomLeft: isSent
                              ? Radius.circular(18.0)
                              : Radius.circular(0),
                          bottomRight: isSent
                              ? Radius.circular(0)
                              : Radius.circular(18.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['text'],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSent ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            message['time'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isSent ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSent) ...[
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/default_avatar.jpg'),
                        radius: 20,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Escribe aquí...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Color(0xFFF2404E),
                    radius: 24,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
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
