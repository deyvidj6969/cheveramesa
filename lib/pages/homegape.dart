import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engineering/widgets/reaturantcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:engineering/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:engineering/pages/restaurant_details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // Obtener la lista de favoritos del usuario actual
  Future<List<String>> _getUserFavorites() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(currentUser.uid)
        .get();
    return List<String>.from(userDoc.data()?['favorites'] ?? []);
  }

  // Actualizar los favoritos en Firestore
  Future<void> _toggleFavorite(String restaurantId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDocRef =
        FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid);

    final userDoc = await userDocRef.get();
    final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);

    if (favorites.contains(restaurantId)) {
      favorites.remove(restaurantId);
    } else {
      favorites.add(restaurantId);
    }

    await userDocRef.update({'favorites': favorites});
    setState(() {}); // Actualizar la UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar Personalizado
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CheveraMesa',
                      style: TextStyle(
                        fontFamily: 'Lobster',
                        fontSize: 28,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Tu reserva a un clic',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/default_avatar.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Campo de búsqueda y botón
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.search, color: Colors.black, size: 24),
                        hintText: 'Ubicación, restaurante o cocina',
                        hintStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      searchQuery = _searchController.text.toLowerCase();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2404E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    '¡Dale!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Grid de restaurantes desde Firestore
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _getUserFavorites(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final userFavorites = snapshot.data ?? [];

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('restaurants')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final restaurants = snapshot.data!.docs.where((doc) {
                      final name = (doc['name'] as String).toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                    if (restaurants.isEmpty) {
                      return Center(
                        child: Text(
                          'No se encontraron resultados',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 600
                            ? (constraints.maxWidth ~/ 300)
                            : 2;

                        double childAspectRatio =
                            constraints.maxWidth > 600 ? 3 / 2 : 3 / 4;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            itemCount: restaurants.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemBuilder: (context, index) {
                              final restaurantData = restaurants[index].data()
                                  as Map<String, dynamic>;

                              final restaurant = Restaurant.fromFirestore(
                                restaurants[index].id,
                                restaurantData,
                              );

                              final isFavorite =
                                  userFavorites.contains(restaurants[index].id);

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestaurantDetails(
                                          restaurant: restaurant),
                                    ),
                                  );
                                },
                                child: RestaurantCard(
                                  id: restaurant.id,
                                  name: restaurant.name,
                                  location: restaurant.location,
                                  rating: restaurant.rating,
                                  price: restaurant.price,
                                  imageUrl: restaurant.image,
                                  isFavorite: isFavorite,
                                  onFavoriteToggle: () =>
                                      _toggleFavorite(restaurant.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
