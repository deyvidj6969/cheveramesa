import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engineering/models/Chats.dart';
import 'package:engineering/pages/chatscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//enviar un mensage

Future<void> sendMessage({
  required String conversationId,
  required String senderId,
  required String message,
}) async {
  try {
    // Crea una instancia de Firestore
    final conversationRef = FirebaseFirestore.instance
        .collection('conversaciones')
        .doc(conversationId);

    // Obtén la conversación actual
    final conversationSnapshot = await conversationRef.get();

    if (!conversationSnapshot.exists) {
      if (kDebugMode) {
        print("Error: La conversación no existe");
      }
      return;
    }

    // Obtén la lista actual de mensajes
    final conversationData = conversationSnapshot.data();
    if (conversationData == null) {
      if (kDebugMode) {
        print("Error: No se pudo obtener la data de la conversación");
      }
      return;
    }

    final List<dynamic> messages = conversationData['messages'] ?? [];

    // Crea el nuevo mensaje
    final newMessage = Messagefirebase(
      senderId: senderId,
      message: message,
      tiempo: DateTime.now(),
      isRead: false, // El mensaje enviado aún no está leído
    ).toMap();

    // Agrega el nuevo mensaje a la lista de mensajes
    messages.add(newMessage);

    // Actualiza la conversación en Firestore
    await conversationRef.update({'messages': messages});
  } catch (e) {
    if (kDebugMode) {
      print("Error al enviar mensaje: $e");
    }
  }
}

Future<void> handleSendMessage({
  required String conversationId,
  required String senderId,
  required String messageText,
  required TextEditingController messageController,
  required Function scrollToBottom,
  required BuildContext context,
  required bool Function(String) containsRestrictedContent,
  required VoidCallback setSendingState,
}) async {
  if (messageText.isEmpty) {
    if (kDebugMode) {
      print("Error: El mensaje está vacío");
    }
    return;
  }

  // Verificar contenido restringido
  if (containsRestrictedContent(messageText)) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 15),
              const Text(
                "¡Tu seguridad es nuestra prioridad!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Para garantizar tu seguridad, evita compartir información personal como números, correos o enlaces.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF2404E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Entendido",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return;
  }

  // Actualizar el estado a 'enviando'
  setSendingState();

  try {
    await sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      message: messageText,
    );

    // Limpiar el campo de entrada
    messageController.clear();

    // Desplazar hacia abajo
    scrollToBottom();
  } catch (e) {
    if (kDebugMode) {
      print("Error al enviar mensaje: $e");
    }
  } finally {
    // Restablecer el estado de envío
    setSendingState();
  }
}

//marcar mensajes como leidos

Future<void> markMessagesAsRead(
    String conversationId, String currentUserId) async {
  final conversationRef = FirebaseFirestore.instance
      .collection('conversaciones')
      .doc(conversationId);

  final conversationSnapshot = await conversationRef.get();
  final messages = (conversationSnapshot.data()!['messages'] as List)
      .map((message) => Messagefirebase.fromMap(message))
      .toList();

  // Actualizar solo los mensajes no leídos enviados al usuario actual
  final updatedMessages = messages.map((message) {
    if (message.senderId != currentUserId && !message.isRead) {
      return message.toMap()..['isRead'] = true;
    }
    return message.toMap();
  }).toList();

  // Guardar los mensajes actualizados en Firestore
  await conversationRef.update({'messages': updatedMessages});
}

//manejaronversacionesnuevas

Future<void> manejarConversacion(
    BuildContext context, String userPublicadorId, String currentUserId) async {
  final restaurantsRef = FirebaseFirestore.instance.collection('restaurants');
  final usersRef = FirebaseFirestore.instance.collection('usuarios');
  final conversacionesRef =
      FirebaseFirestore.instance.collection('conversaciones');

  try {
    // Obtener datos del publicador
    final publicadorSnapshot = await restaurantsRef.doc(userPublicadorId).get();
    if (!publicadorSnapshot.exists) {
      if (kDebugMode) {
        print(
            'El documento con id $userPublicadorId no existe en la colección restarants.');
      }
      return;
    }

    final publicadorData = publicadorSnapshot.data();
    List<dynamic> idConversacionesPublicador = [];
    if (publicadorData != null &&
        publicadorData.containsKey('idconversaciones')) {
      idConversacionesPublicador =
          publicadorData['idconversaciones'] as List<dynamic>;
    } else {
      // Inicializar el campo idconversaciones si no existe
      await restaurantsRef.doc(userPublicadorId).set({
        'idconversaciones': [],
      }, SetOptions(merge: true));
    }

    // Obtener datos del usuario actual
    final currentUserSnapshot = await usersRef.doc(currentUserId).get();
    if (!currentUserSnapshot.exists) {
      if (kDebugMode) {
        print(
            'El documento con id $currentUserId no existe en la colección users.');
      }
      return;
    }

    final currentUserData = currentUserSnapshot.data();
    List<dynamic> idConversacionesCurrentUser = [];
    if (currentUserData != null &&
        currentUserData.containsKey('idconversaciones')) {
      idConversacionesCurrentUser =
          currentUserData['idconversaciones'] as List<dynamic>;
    } else {
      // Inicializar el campo idconversaciones si no existe
      await usersRef.doc(currentUserId).set({
        'idconversaciones': [],
      }, SetOptions(merge: true));
    }

    // Comparar los arrays para encontrar coincidencias
    final coincidencias = idConversacionesPublicador
        .where((id) => idConversacionesCurrentUser.contains(id))
        .toList();

    if (coincidencias.isNotEmpty) {
      final primeraCoincidencia = coincidencias.first as String;

      // Navegar al ChatScreen con la conversación existente
      final conversationSnapshot =
          await conversacionesRef.doc(primeraCoincidencia).get();

      if (conversationSnapshot.exists) {
        final conversationData = conversationSnapshot.data();
        if (conversationData != null) {
          final conversation =
              Conversation.fromFirestore(primeraCoincidencia, conversationData);

          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversation: conversation,
                currentUserId: currentUserId,
                otherUserPhotoUrl:
                    publicadorData?['image'], // Ajusta al campo real
                otherUserName: publicadorData?['name'], // Ajusta al campo real
              ),
            ),
          );
        }
      }
    } else {
      // No hay coincidencias: Crear una nueva conversación
      final nuevaConversacionRef = conversacionesRef.doc();

      final nuevaConversacion = Conversation(
          id: nuevaConversacionRef.id,
          idPublicacion: 'ID_PUBLICACION', // Reemplaza con el ID adecuado
          type: 'texto', // Define el tipo según tu lógica
          user1Id: currentUserId,
          user2Id: userPublicadorId,
          messages: [],
          priceacorded: 0);

      await nuevaConversacionRef.set({
        'idpublicacion': nuevaConversacion.idPublicacion,
        'type': nuevaConversacion.type,
        'user1Id': nuevaConversacion.user1Id,
        'user2Id': nuevaConversacion.user2Id,
        'messages': [],
      });

      // Actualizar los arrays de idconversaciones en ambos usuarios
      await restaurantsRef.doc(userPublicadorId).update({
        'idconversaciones': FieldValue.arrayUnion([nuevaConversacionRef.id]),
      });

      await usersRef.doc(currentUserId).update({
        'idconversaciones': FieldValue.arrayUnion([nuevaConversacionRef.id]),
      });

      // Navegar al ChatScreen con la nueva conversación
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversation: nuevaConversacion,
            currentUserId: currentUserId,
            otherUserPhotoUrl: publicadorData?['image'], // Ajusta al campo real
            otherUserName: publicadorData?['name'], // Ajusta al campo real
          ),
        ),
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error al manejar la conversación: $e');
    }
  }
}

//formatear fecha chats
String formatTime(DateTime dateTime) {
  return DateFormat('hh:mm a').format(dateTime); // Ejemplo: "7:12 AM"
}
//label de separacion dias

String formatDateLabel(DateTime date) {
  final today = DateTime.now();
  if (date.day == today.day &&
      date.month == today.month &&
      date.year == today.year) {
    return 'Hoy';
  } else if (date.day == today.subtract(const Duration(days: 1)).day &&
      date.month == today.month &&
      date.year == today.year) {
    return 'Ayer';
  } else {
    return DateFormat('EEEE, d \'de\' MMMM', 'es').format(date).toLowerCase();
    // Ejemplo: "lunes, 16 de septiembre"
  }
}
