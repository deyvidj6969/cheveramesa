import 'package:flutter/material.dart';

class CreateNewRestaurant extends StatelessWidget {
  final String currentUserId;

  const CreateNewRestaurant({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Nuevo Restaurante'),
        backgroundColor: Color(0xFFF2404E),
      ),
      body: Center(
        child: Text('Aquí podrás crear un nuevo restaurante'),
      ),
    );
  }
}
