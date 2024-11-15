import 'package:engineering/models/UserModel.dart';
import 'package:engineering/pages/login.dart';
import 'package:engineering/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? currentUserModel;

  // Controlador para editar el nombre
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          currentUserModel = UserModel.fromFirestore(
              doc.data() as Map<String, dynamic>, user.uid);
          _nameController.text = currentUserModel!.nombre;
        });
      }
    }
  }

  // Actualizar el nombre en Firestore
  Future<void> _updateName() async {
    if (currentUserModel != null) {
      try {
        await _firestore
            .collection('usuarios')
            .doc(currentUserModel!.uid)
            .update({
          'nombre': _nameController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nombre actualizado con éxito.")),
        );
        _loadUserData(); // Recargar los datos actualizados
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar el nombre: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFF2404E),
        elevation: 0,
      ),
      body: currentUserModel == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  color: Color(0xFFF2404E),
                  child: Column(
                    children: [
                      // Fondo rojo degradado
                      Container(
                        height: 100,
                        color: Color(0xFFF2404E),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: ListView(
                            children: [
                              SizedBox(height: 40), // Espacio para la imagen
                              _buildProfileField(
                                  "Nombre", currentUserModel!.nombre,
                                  isEditable: true,
                                  controller: _nameController),
                              _buildProfileField(
                                  "Correo", currentUserModel!.correo),
                              _buildProfileField("Rol", currentUserModel!.rol),

                              SizedBox(height: 24),

                              // Botones de acciones
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await _updateName();
                                    },
                                    icon: Icon(
                                      Icons.save,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Guardar Cambios",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      await _authService
                                          .signOut(); // Cerrar sesión
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                      );
                                    },
                                    icon: Icon(Icons.logout,
                                        color: Color(0xFFF2404E)),
                                    label: Text(
                                      "Cerrar sesión",
                                      style:
                                          TextStyle(color: Color(0xFFF2404E)),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side:
                                          BorderSide(color: Color(0xFFF2404E)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Imagen de perfil cuadrada y sobresaliente
                Positioned(
                  top: 30,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/default_avatar.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileField(String label, String value,
      {bool isEditable = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 5),
          isEditable
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
