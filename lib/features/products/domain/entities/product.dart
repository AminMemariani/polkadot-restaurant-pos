import 'package:equatable/equatable.dart';

/// Product entity representing a menu item
class Product extends Equatable {
  final String id;
  final String name;
  final double price;

  const Product({required this.id, required this.name, required this.price});

  /// Create a copy of this product with updated fields
  Product copyWith({String? id, String? name, double? price}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }

  @override
  List<Object?> get props => [id, name, price];

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }
}
