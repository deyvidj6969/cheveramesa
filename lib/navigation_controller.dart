import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engineering/mainpage.dart';
import 'package:engineering/pages/login.dart';
import 'package:engineering/screens/MainRestaurant.dart';
import 'package:engineering/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationController extends StatefulWidget {
  @override
  _NavigationControllerState createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  bool _showSplash = true;
  User? _currentUser;
  String? _userRole; // Para almacenar el rol del usuario

  @override
  void initState() {
    super.initState();
    // Muestra el SplashScreen por 5 segundos y verifica el usuario actual
    Timer(Duration(seconds: 5), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Si hay un usuario autenticado, obtén su rol desde Firestore
        await _fetchUserRole(user.uid);
      }

      setState(() {
        _currentUser = user;
        _showSplash = false;
      });
    });
  }

  Future<void> _fetchUserRole(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _userRole = data?['rol'] ?? 'Usuario'; // Predetermina a "Usuario"
        });
      }
    } catch (e) {
      debugPrint('Error al obtener el rol del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(); // Mostrar pantalla de carga
    }

    if (_currentUser == null) {
      return LoginPage(); // Si no hay usuario autenticado, navega al LoginPage
    }

    // Si hay un usuario autenticado, redirige según su rol
    if (_userRole == 'Dueño de Restaurante') {
      return MainRestaurante(); // Navega a MainRestaurante
    }

    return MainPage(); // Navega a MainPage para usuarios normales
  }
}
