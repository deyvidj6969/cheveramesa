import 'package:engineering/funtions/funtions.dart';
import 'package:engineering/mainpage.dart';
import 'package:engineering/models/Chats.dart';
import 'package:engineering/pages/chatscreen.dart';
import 'package:engineering/widgets/MyWdgButton.dart';
import 'package:engineering/widgets/MyWdgCardMessage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationsScreen extends StatefulWidget {
  final String currentUserId;

  const ConversationsScreen({super.key, required this.currentUserId});

  @override
  ConversationsScreenState createState() => ConversationsScreenState();
}

class ConversationsScreenState extends State<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 242, 245),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        title: const Text(
          "Mensajes",
          textScaleFactor: 1.5,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.currentUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null || !userData.containsKey('idconversaciones')) {
            return _noMessagesUI(context);
          }

          final userConversations = userData['idconversaciones'] as List;

          if (userConversations.isEmpty) {
            return _noMessagesUI(context);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('conversaciones')
                .where(FieldPath.documentId, whereIn: userConversations)
                .snapshots(),
            builder: (context, conversationsSnapshot) {
              if (!conversationsSnapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Colors.black,
                ));
              }

              final conversationsDocs = conversationsSnapshot.data!.docs;

              if (conversationsDocs.isEmpty) {
                return _noMessagesUI(context);
              }

              final conversations = conversationsDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Conversation.fromFirestore(doc.id, data);
              }).toList();

              // Ordenar las conversaciones por la marca de tiempo del último mensaje
              conversations.sort((a, b) {
                final lastMessageA = a.messages.isNotEmpty
                    ? a.messages.last.tiempo
                    : DateTime(0);
                final lastMessageB = b.messages.isNotEmpty
                    ? b.messages.last.tiempo
                    : DateTime(0);
                return lastMessageB.compareTo(lastMessageA);
              });

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];

                  final lastMessage = conversation.messages.isNotEmpty
                      ? conversation.messages.last
                      : null;

                  final otherUserId =
                      conversation.user1Id == widget.currentUserId
                          ? conversation.user2Id
                          : conversation.user1Id;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('restaurants')
                        .doc(otherUserId)
                        .snapshots(),
                    builder: (context, otherUserSnapshot) {
                      if (!otherUserSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final otherUserData = otherUserSnapshot.data!.data()
                          as Map<String, dynamic>;
                      final displayName = otherUserData['name'] ?? 'Usuario';
                      final photoUrl = otherUserData['image'] ?? '';

                      return MyWdgCardMessage(
                        name: displayName,
                        ultimoMensaje: lastMessage?.message ?? '',
                        time: lastMessage?.tiempo ?? DateTime.now(),
                        urlImage: photoUrl,
                        currentUserId: widget.currentUserId,
                        ultimoMensajeSenderId: lastMessage?.senderId ?? '',
                        ultimoMensajeIsRead: lastMessage?.isRead ?? false,
                        onPressed: () {
                          // Navegar a la pantalla de chat y marcar mensajes como leídos
                          markMessagesAsRead(
                              conversation.id, widget.currentUserId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversation: conversation,
                                currentUserId: widget.currentUserId,
                                otherUserPhotoUrl: photoUrl,
                                otherUserName: displayName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _noMessagesUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No tienes mensajes todavía.",
            textScaleFactor: 1.8,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Aquí puedes comunicarte directamente con los restaurantes para resolver dudas, realizar consultas o coordinar tus reservaciones.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            child: MyWdgButton(
              text: "Explorar Restaurantes",
              color: const Color(0xFFF2404E),
              colorFont: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
