import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final String id; // ID del restaurante
  final String name;
  final String location;
  final double rating;
  final String price;
  final String imageUrl;
  final bool isFavorite; // Estado del favorito
  final VoidCallback onFavoriteToggle; // Callback para manejar el favorito

  const RestaurantCard({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis, // Evita desbordamientos largos
                ),
                Text(
                  location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "Desde $price",
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
