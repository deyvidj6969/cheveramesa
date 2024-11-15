import 'package:cloud_firestore/cloud_firestore.dart';

class Messagefirebase {
  final String senderId;
  final String message;
  final DateTime tiempo;
  final bool isRead;

  Messagefirebase({
    required this.senderId,
    required this.message,
    required this.tiempo,
    this.isRead = false,
  });

  factory Messagefirebase.fromMap(Map<String, dynamic> map) {
    return Messagefirebase(
      senderId: map['senderId'],
      message: map['message'],
      tiempo: (map['tiempo'] as Timestamp).toDate(),
      isRead:
          map['isRead'] ?? false, // Por defecto es false si no está presente
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'message': message,
      'tiempo': Timestamp.fromDate(tiempo),
      'isRead': isRead,
    };
  }
}

class Conversation {
  final String id;
  final String idPublicacion;
  final String type;
  final String user1Id;
  final String user2Id;
  final List<Messagefirebase> messages;
  final int priceacorded;

  Conversation({
    required this.id,
    required this.idPublicacion,
    required this.type,
    required this.user1Id,
    required this.user2Id,
    required this.messages,
    required this.priceacorded,
  });

  factory Conversation.fromFirestore(String id, Map<String, dynamic> map) {
    return Conversation(
        id: id,
        idPublicacion: map['idpublicacion'],
        type: map['type'],
        user1Id: map['user1Id'],
        user2Id: map['user2Id'],
        messages: (map['messages'] as List)
            .map((message) => Messagefirebase.fromMap(message))
            .toList(),
        priceacorded: map['priceacorded'] ?? 0);
  }
}
