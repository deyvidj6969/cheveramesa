import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicia sesión con Google y guarda los datos del usuario en Firestore
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // El usuario canceló la operación

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Verifica si el documento ya existe
        final DocumentSnapshot userDoc =
            await _firestore.collection('usuarios').doc(user.uid).get();

        if (!userDoc.exists) {
          // Si el documento no existe, crea uno nuevo
          await _firestore.collection('usuarios').doc(user.uid).set({
            'nombre': user.displayName ?? 'Sin Nombre',
            'correo': user.email ?? 'Sin Correo',
            'urlfoto': user.photoURL ?? '',
            'uid': user.uid,
            'rol': 'Usuario', // Rol predeterminado
          });
        } else {
          // Si el documento ya existe, actualiza los datos
          await _firestore.collection('usuarios').doc(user.uid).update({
            'nombre': user.displayName ?? 'Sin Nombre',
            'correo': user.email ?? 'Sin Correo',
            'urlfoto': user.photoURL ?? '',
          });
        }
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error en loginWithGoogle: $e');
      }
      return null;
    }
  }

  /// Inicia sesión con correo y contraseña
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Error en signInWithEmailAndPassword: $e');
      }
      return null;
    }
  }

  /// Registra un usuario con correo y contraseña y guarda sus datos en Firestore
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String nombre, String rol) async {
    try {
      // Crear usuario con correo y contraseña
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Guardar los datos del usuario en Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nombre': nombre,
          'correo': email.trim(),
          'rol': rol,
          'uid': user.uid,
        });
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error en registerWithEmailAndPassword: $e');
      }
      return null;
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error en signOut: $e');
      }
    }
  }

  /// Obtiene el usuario actual
  User? get currentUser {
    return _firebaseAuth.currentUser;
  }
}
