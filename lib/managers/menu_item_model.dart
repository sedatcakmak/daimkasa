class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final int maximum;
  final int stars;
  final String description;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
    required this.stars,
    required this.maximum,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      stars: data['stars'] ?? 0,
      maximum: data['maximum'] ?? 0,
    );
  }
}
