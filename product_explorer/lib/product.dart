/// A single item from fakestoreapi.com.
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String image;
  final double rating;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        category: json['category'] as String,
        image: json['image'] as String? ?? '',
        rating: ((json['rating'] as Map?)?['rate'] as num?)?.toDouble() ?? 0,
      );
}
