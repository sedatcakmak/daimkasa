import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daimkasa/managers/order_item_model.dart';
import 'package:daimkasa/managers/user_model.dart';

class OrderModel {
  String id;
  final String userId;
  final String restaurantId;
  final double totalPrice;
  final double usedBalance;
  List<OrderItemModel> items;
  late UserModel? userModel;
  late Timestamp date;

  OrderModel({
    required this.id,
    required this.restaurantId,
    required this.totalPrice,
    required this.usedBalance,
    required this.userId,
    this.items = const [],
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
        id: id,
        restaurantId: data['restaurant_id'] ?? '',
        userId: data['user_id'] ?? '',
        totalPrice: (data['total_price'] ?? 0).toDouble(),
        usedBalance: (data['used_balance'] ?? 0).toDouble());
  }
}
