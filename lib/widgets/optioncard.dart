// Método para construir cada opción (fecha, hora, personas) con ancho personalizado
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buildOptionCard(IconData icon, String text, double width) {
  return Container(
    width: width, // Ancho personalizado
    height: 48, // Altura de la tarjeta
    padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 14, color: Colors.black), // Icono negro
        SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.black),
            overflow:
                TextOverflow.ellipsis, // Ajuste de texto para evitar overflow
          ),
        ),
        Icon(Icons.arrow_drop_down,
            size: 14, color: Colors.black), // Flecha negra
      ],
    ),
  );
}
