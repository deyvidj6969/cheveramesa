import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:engineering/screens/CreateNewRestaurant.dart';

class RestaurantService {
  Future<Map<String, dynamic>?> fetchRestaurantData(
      String currentUserId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('idDueno', isEqualTo: currentUserId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'restaurantId': doc.id,
          ...doc.data(),
        };
      }
      return null;
    } catch (e) {
      print('Error fetching restaurant data: $e');
      return null;
    }
  }

  Future<String> uploadImageToStorage(String path) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('restaurants/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(File(path));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> updateRestaurant({
    required String restaurantId,
    required String name,
    required String description,
    required String location,
    required String mainImageUrl,
    required List<String> secondaryImages,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .update({
        'name': name,
        'description': description,
        'location': location,
        'image': mainImageUrl,
        'secondaryImages': secondaryImages,
      });
    } catch (e) {
      print('Error updating restaurant: $e');
      rethrow;
    }
  }

  Future<void> navigateToAddRestaurant(
      BuildContext context, String currentUserId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewRestaurant(
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  Future<String?> pickImage({bool isMain = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return pickedFile.path;
    }
    return null;
  }
}
