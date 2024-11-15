class UserModel {
  final String uid;
  final String correo;
  final String nombre;
  final String rol;

  UserModel({
    required this.uid,
    required this.correo,
    required this.nombre,
    required this.rol,
  });

  // Método para convertir desde Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      correo: data['correo'] ?? '',
      nombre: data['nombre'] ?? 'Sin Nombre',
      rol: data['rol'] ?? 'Usuario',
    );
  }

  // Método para convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'correo': correo,
      'nombre': nombre,
      'rol': rol,
    };
  }
}
