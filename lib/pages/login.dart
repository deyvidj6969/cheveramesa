import 'package:engineering/screens/MainRestaurant.dart';
import 'package:engineering/services/auth_services.dart';
import 'package:engineering/mainpage.dart'; // Importa la MainPage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = "Usuario";

  bool _isRegistering = false;

  /// Navega al home correspondiente basado en el rol del usuario
  void navigateToHome(String userId) async {
    final userDoc = await _firestore.collection('usuarios').doc(userId).get();
    if (userDoc.exists) {
      final role = userDoc.data()?['rol'] ?? 'Usuario';
      if (role == 'Dueño de Restaurante') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainRestaurante()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } else {
      // Si el usuario no tiene datos en Firestore, redirigir a MainPage por defecto
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de la app
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),

                // Título de la app
                Text(
                  'CheveraMesa',
                  style: TextStyle(
                    fontFamily: 'Lobster',
                    fontSize: 36,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tu reserva a un clic',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),

                // Campos adicionales para registro
                if (_isRegistering)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre completo',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                if (_isRegistering) SizedBox(height: 20),

                // Campo de correo electrónico
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Campo de contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Selección de rol (solo para registro)
                if (_isRegistering)
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: _selectedRole,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text('Usuario'),
                        value: 'Usuario',
                      ),
                      DropdownMenuItem(
                        child: Text('Dueño de Restaurante'),
                        value: 'Dueño de Restaurante',
                      ),
                    ],
                  ),
                SizedBox(height: 30),

                // Botón principal
                ElevatedButton(
                  onPressed: () async {
                    if (_isRegistering) {
                      // Registro
                      final user =
                          await _authService.registerWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                        _selectedRole,
                      );
                      if (user != null) {
                        navigateToHome(user.uid);
                      }
                    } else {
                      // Inicio de sesión
                      final user =
                          await _authService.signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (user != null) {
                        navigateToHome(user.uid);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2404E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    _isRegistering ? 'Registrarse' : 'Iniciar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Alternar entre login y registro
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? '¿Ya tienes una cuenta? Inicia sesión'
                        : '¿No tienes una cuenta? Regístrate',
                    style: TextStyle(color: Color(0xFFF2404E)),
                  ),
                ),
                SizedBox(height: 20),

                // Botón de inicio de sesión con Google
                // Botón de inicio de sesión con Google
                OutlinedButton.icon(
                  onPressed: () async {
                    final userCredential = await _authService.loginWithGoogle();
                    if (userCredential != null && userCredential.user != null) {
                      navigateToHome(userCredential
                          .user!.uid); // Accede al UID del usuario
                    }
                  },
                  icon: Icon(Icons.login, color: Color(0xFFF2404E)),
                  label: Text(
                    'Iniciar sesión con Google',
                    style: TextStyle(color: Color(0xFFF2404E)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
