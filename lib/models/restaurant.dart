class Restaurant {
  final String id; // ID del documento
  final String name;
  final String location;
  final double rating;
  final String price;
  final String image;
  final String description;
  final List<Review> resenas;
  final List<String> idconversaciones;
  final List<String> secondaryImages; // Lista de fotos secundarias
  final Map<String, List<MenuItem>> menu; // Menú categorizado

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.image,
    required this.description,
    required this.resenas,
    required this.idconversaciones,
    required this.secondaryImages,
    required this.menu,
  });

  // Método para convertir desde un documento de Firestore
  factory Restaurant.fromFirestore(String id, Map<String, dynamic> data) {
    return Restaurant(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      price: data['price'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      resenas: (data['resenas'] as List<dynamic>? ?? [])
          .map((resena) => Review.fromFirestore(resena))
          .toList(),
      idconversaciones: List<String>.from(data['idconversaciones'] ?? []),
      secondaryImages: List<String>.from(data['secondaryImages'] ?? []),
      menu: (data['menu'] as Map<String, dynamic>? ?? {}).map((key, value) {
        return MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) => MenuItem.fromFirestore(item))
              .toList(),
        );
      }),
    );
  }
}

class Review {
  final String userName;
  final double rating;
  final String comment;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
  });

  // Método para convertir desde un documento de Firestore
  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      userName: data['userName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
    );
  }
}

class MenuItem {
  final String name;
  final String description;
  final String price;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
  });

  // Método para convertir desde un documento de Firestore
  factory MenuItem.fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? '',
    );
  }
}
