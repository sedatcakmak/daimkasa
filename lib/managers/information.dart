import 'package:daimkasa/managers/order_model.dart';
import 'package:daimkasa/managers/restaurant_model.dart';

class Information {
  static String id = "";
  static String name = "";
  static String surname = "";
  static String phone = "";
  static String restaurantId = "";
  static RestaurantModel? restaurant;
  static int orderCount = 0;
  static double priceCount = 0;
  static List<OrderModel> orders = [];
}
