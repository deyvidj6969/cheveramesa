import 'package:engineering/funtions/funtions.dart';
import 'package:engineering/models/Chats.dart';
import 'package:engineering/widgets/messagewidgets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;
  final String otherUserPhotoUrl;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.otherUserPhotoUrl,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  // Verificar contenido restringido
  bool _containsRestrictedContent(String message) {
    final phonePattern = RegExp(r'(\+?\d[\d -]{8,}\d)');
    final emailPattern =
        RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final urlPattern = RegExp(r'http[s]?:\/\/[^\s]+');

    return phonePattern.hasMatch(message) ||
        emailPattern.hasMatch(message) ||
        urlPattern.hasMatch(message);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Desplázate al fondo cuando el teclado se abre
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 242, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CachedNetworkImage(
                imageUrl: widget.otherUserPhotoUrl,
                width: 40,
                height: 40,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.otherUserName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('conversaciones')
                      .doc(widget.conversation.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }

                    final conversationData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    final List<dynamic> messagesData =
                        conversationData['messages'] ?? [];
                    final List<Messagefirebase> messages = messagesData
                        .map((message) => Messagefirebase.fromMap(
                            message as Map<String, dynamic>))
                        .toList();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == widget.currentUserId;

                        final currentMessageDate = message.tiempo;
                        final previousMessageDate =
                            index > 0 ? messages[index - 1].tiempo : null;

                        final showDateLabel = previousMessageDate == null ||
                            currentMessageDate.day != previousMessageDate.day ||
                            currentMessageDate.month !=
                                previousMessageDate.month ||
                            currentMessageDate.year != previousMessageDate.year;

                        return MessageWidget(
                          message: message,
                          isMe: isMe,
                          showDateLabel: showDateLabel,
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "Escribe un mensaje...",
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xFFF2404E),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _isSending
                            ? null
                            : () {
                                handleSendMessage(
                                  conversationId: widget.conversation.id,
                                  senderId: widget.currentUserId,
                                  messageText: _messageController.text.trim(),
                                  messageController: _messageController,
                                  scrollToBottom: _scrollToBottom,
                                  context: context,
                                  containsRestrictedContent:
                                      _containsRestrictedContent,
                                  setSendingState: () {
                                    setState(() {
                                      _isSending = !_isSending;
                                    });
                                  },
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              )
            ],
          );
        },
      ),
    );
  }
}
