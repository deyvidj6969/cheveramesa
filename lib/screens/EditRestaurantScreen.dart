import 'dart:io';
import 'package:engineering/pages/login.dart';
import 'package:engineering/screens/CreateNewRestaurant.dart';
import 'package:engineering/widgets/MyWdgButton.dart';
import 'package:engineering/widgets/MyWdgTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditRestaurantScreen extends StatefulWidget {
  final String currentUserId;

  const EditRestaurantScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  bool isLoading = true;
  Map<String, dynamic>? restaurantData;
  String? restaurantId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String mainImageUrl = '';
  List<String> secondaryImages = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  Future<void> _fetchRestaurantData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('idDueno', isEqualTo: widget.currentUserId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        restaurantId = doc.id;
        restaurantData = doc.data();

        _nameController.text = restaurantData!['name'] ?? '';
        _descriptionController.text = restaurantData!['description'] ?? '';
        _locationController.text = restaurantData!['location'] ?? '';
        mainImageUrl = restaurantData!['image'] ?? '';
        secondaryImages =
            List<String>.from(restaurantData!['secondaryImages'] ?? []);
      } else {
        restaurantData = null; // No hay restaurante
      }
    } catch (e) {
      print('Error fetching restaurant data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _uploadImageToStorage(String path, {bool isMain = false}) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('restaurants/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(File(path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        if (isMain) {
          mainImageUrl = downloadUrl;
        } else {
          secondaryImages.add(downloadUrl);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen subida exitosamente.')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen.')),
      );
    }
  }

  Future<void> _pickImage({bool isMain = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadImageToStorage(pickedFile.path, isMain: isMain);
    }
  }

  Future<void> _updateRestaurant() async {
    if (restaurantId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'image': mainImageUrl,
        'secondaryImages': secondaryImages,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restaurante actualizado exitosamente.')),
      );
    } catch (e) {
      print('Error updating restaurant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el restaurante.')),
      );
    }
  }

  Future<void> _navigateToAddRestaurant() async {
    // Aquí debes navegar a la página para agregar un restaurante
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewRestaurant(
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (restaurantData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mi Restaurante',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFF2404E),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Cerrar Sesión'),
                    content: const Text(
                      '¿Estás seguro de que deseas cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Cierra el diálogo
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'No tienes un restaurante asociado.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: MyWdgButton(
                    text: 'Agregar Restaurante',
                    onPressed: _navigateToAddRestaurant,
                    color: const Color(0xFFF2404E),
                    colorFont: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Restaurante',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF2404E),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Cerrar Sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar el diálogo
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyWdgTextField(
                text: 'Nombre del restaurante',
                textEditingController: _nameController,
                labelText: 'Nombre',
                enabled: true,
              ),
              const SizedBox(height: 16),
              MyWdgTextField(
                text: 'Descripción',
                textEditingController: _descriptionController,
                labelText: 'Descripción',
                maxLines: 3,
                enabled: true,
              ),
              const SizedBox(height: 16),
              MyWdgTextField(
                text: 'Ubicación',
                textEditingController: _locationController,
                labelText: 'Ubicación',
                enabled: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Imagen Principal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickImage(isMain: true),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: mainImageUrl.isNotEmpty
                          ? Image.network(
                              mainImageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.add_a_photo, size: 50),
                            ),
                    ),
                    if (mainImageUrl.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.red),
                          onPressed: () => _pickImage(isMain: true),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Imágenes Secundarias',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: secondaryImages
                    .map((imageUrl) => Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    secondaryImages.remove(imageUrl);
                                  });
                                },
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: MyWdgButton(
                  text: 'Añadir Imagen Secundaria',
                  onPressed: _pickImage,
                  color: Colors.white,
                  colorFont: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: MyWdgButton(
                  text: 'Guardar Cambios',
                  onPressed: _updateRestaurant,
                  color: const Color(0xFFF2404E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
