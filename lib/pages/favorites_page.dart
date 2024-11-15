import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engineering/mainpage.dart';
import 'package:engineering/models/restaurant.dart';
import 'package:engineering/widgets/FavoriteCard.dart';
import 'package:engineering/widgets/MyWdgButton.dart';
import 'package:flutter/material.dart';
import 'restaurant_details.dart';

class FavoritesPage extends StatelessWidget {
  final String currentUserId;

  const FavoritesPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favoritos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFF2404E),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return _noFavoritesUI(context);
          }

          // Convierte los datos del snapshot a Map<String, dynamic>
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          // Verifica si el campo "favorites" existe y no está vacío
          final List<String> favoriteRestaurantIds =
              userData['favorites'] != null
                  ? List<String>.from(userData['favorites'])
                  : [];

          if (favoriteRestaurantIds.isEmpty) {
            return _noFavoritesUI(context);
          }

          // Stream para obtener detalles de los restaurantes favoritos
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .where(FieldPath.documentId, whereIn: favoriteRestaurantIds)
                .snapshots(),
            builder: (context, restaurantSnapshot) {
              if (restaurantSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!restaurantSnapshot.hasData ||
                  restaurantSnapshot.data!.docs.isEmpty) {
                return _noFavoritesUI(context);
              }

              final favoriteRestaurants = restaurantSnapshot.data!.docs.map(
                (doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Restaurant.fromFirestore(doc.id, data);
                },
              ).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: favoriteRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = favoriteRestaurants[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetails(
                            restaurant: restaurant,
                          ),
                        ),
                      );
                    },
                    child: FavoriteCard(
                      name: restaurant.name,
                      location: restaurant.location,
                      rating: restaurant.rating,
                      price: restaurant.price,
                      imageUrl: restaurant.image,
                      description: restaurant.description,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _noFavoritesUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No tienes favoritos todavía.",
              textScaleFactor: 1.8,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Añade tus restaurantes favoritos para acceder rápidamente a ellos.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 60,
              child: MyWdgButton(
                text: "Explorar Restaurantes",
                color: const Color(0xFFF2404E),
                colorFont: Colors.white,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
