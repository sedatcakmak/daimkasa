import 'package:daimkasa/managers/menu_item_model.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String image;
  final List<MenuItemModel> menu;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.menu,
    required this.image,
  });

  factory RestaurantModel.fromMap(
      String id, Map<String, dynamic> data, List<MenuItemModel> menu) {
    return RestaurantModel(
        id: id,
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        menu: menu);
  }
}
