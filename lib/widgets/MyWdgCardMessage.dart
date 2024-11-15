import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyWdgCardMessage extends StatelessWidget {
  final String name;
  final String ultimoMensaje;
  final DateTime time;
  final String urlImage;
  final VoidCallback onPressed;
  final String currentUserId;
  final String ultimoMensajeSenderId;
  final bool ultimoMensajeIsRead;

  const MyWdgCardMessage({
    super.key,
    required this.name,
    required this.ultimoMensaje,
    required this.time,
    required this.urlImage,
    required this.onPressed,
    required this.currentUserId,
    required this.ultimoMensajeSenderId,
    required this.ultimoMensajeIsRead,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            // Imagen de perfil
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: urlImage,
                width: 60,
                height: 60,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
            ),
            const SizedBox(width: 10),
            // Información del chat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Nombre del contacto
                      Expanded(
                        child: Text(
                          name,
                          textScaleFactor: 1.2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Fecha del último mensaje
                      Text(
                        formatDay(time), // Usar la nueva función
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Último mensaje
                  Text(
                    ultimoMensaje,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Indicadores de acciones
            Column(
              children: [
                if (ultimoMensaje != "")
                  ultimoMensajeSenderId == currentUserId
                      ? Icon(
                          Icons.done_all,
                          color: ultimoMensajeIsRead
                              ? Colors
                                  .blue // Azul si el destinatario leyó el mensaje
                              : Colors
                                  .grey, // Gris si el mensaje no ha sido leído
                          size: 16,
                        )
                      : (ultimoMensajeIsRead
                          ? const SizedBox
                              .shrink() // No mostrar nada si ya fue leído
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors
                                    .blue, // Punto azul si no ha sido leído
                                shape: BoxShape.circle,
                              ),
                            )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Función para formatear el día
String formatDay(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0 && now.day == date.day) {
    // Si es de hoy, mostrar la hora
    return DateFormat('HH:mm').format(date);
  } else if (difference.inDays == 1 || (now.day - date.day == 1)) {
    // Si es de ayer, mostrar "ayer"
    return "ayer";
  } else if (difference.inDays < 7) {
    // Si es de esta semana, mostrar el día de la semana
    final days = [
      'domingo',
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado'
    ];
    return days[date.weekday % 7];
  } else {
    // Si es más antiguo, mostrar la fecha completa
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
