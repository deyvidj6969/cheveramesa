import 'package:flutter/material.dart';

Widget buildTimeSlotButton(String time) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: Color(0xFFF2404E), // Color rojo de fondo
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      time,
      style: TextStyle(
        color: Colors.white, // Texto en blanco
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
