import 'package:engineering/funtions/funtions.dart';
import 'package:engineering/mainpage.dart';
import 'package:engineering/models/Chats.dart';
import 'package:engineering/pages/chatscreen.dart';
import 'package:engineering/widgets/MyWdgButton.dart';
import 'package:engineering/widgets/MyWdgCardMessage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantMessagesScreen extends StatefulWidget {
  final String currentUserUid;

  const RestaurantMessagesScreen({super.key, required this.currentUserUid});

  @override
  _RestaurantMessagesScreenState createState() =>
      _RestaurantMessagesScreenState();
}

class _RestaurantMessagesScreenState extends State<RestaurantMessagesScreen> {
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
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .where('idDueno', isEqualTo: widget.currentUserUid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          }

          if (snapshot.data!.docs.isEmpty) {
            return _noMessagesUI(context);
          }

          // Tomar el primer restaurante encontrado (asumiendo que cada dueño tiene un restaurante único)
          final restaurantDoc = snapshot.data!.docs.first;
          final restaurantData = restaurantDoc.data() as Map<String, dynamic>?;

          if (restaurantData == null ||
              !restaurantData.containsKey('idconversaciones')) {
            return _noMessagesUI(context);
          }

          final restaurantConversations =
              restaurantData['idconversaciones'] as List;

          if (restaurantConversations.isEmpty) {
            return _noMessagesUI(context);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('conversaciones')
                .where(FieldPath.documentId, whereIn: restaurantConversations)
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
                      conversation.user1Id == widget.currentUserUid
                          ? conversation.user2Id
                          : conversation.user1Id;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(otherUserId)
                        .snapshots(),
                    builder: (context, otherUserSnapshot) {
                      if (!otherUserSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final otherUserData = otherUserSnapshot.data!.data()
                          as Map<String, dynamic>;
                      final displayName = otherUserData['nombre'] ?? 'Usuario';
                      final photoUrl = otherUserData['photoUrl'] ?? '';

                      return MyWdgCardMessage(
                        name: displayName,
                        ultimoMensaje: lastMessage?.message ?? '',
                        time: lastMessage?.tiempo ?? DateTime.now(),
                        urlImage: photoUrl,
                        currentUserId: widget.currentUserUid,
                        ultimoMensajeSenderId: lastMessage?.senderId ?? '',
                        ultimoMensajeIsRead: lastMessage?.isRead ?? false,
                        onPressed: () {
                          // Navegar a la pantalla de chat y marcar mensajes como leídos
                          markMessagesAsRead(
                              conversation.id, widget.currentUserUid);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversation: conversation,
                                currentUserId: widget.currentUserUid,
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
    return Center(
      child: Padding(
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
              "Aquí aparecerán los mensajes que recibas de tus clientes.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              child: MyWdgButton(
                text: "Explorar",
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
      ),
    );
  }
}
