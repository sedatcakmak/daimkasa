import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daimkasa/managers/information.dart';
import 'package:daimkasa/managers/menu_item_model.dart';
import 'package:daimkasa/managers/order_item_model.dart';
import 'package:daimkasa/managers/order_model.dart';
import 'package:daimkasa/managers/restaurant_model.dart';
import 'package:daimkasa/managers/user_model.dart';

class AppLoader {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<void> loadAllData(String phone) async {
    Map<String, dynamic>? data = await getEmployeeByPhone(phone);
    if (data == null) return;

    Information.name = data["name"] ?? "?";
    Information.surname = data["surname"] ?? "?";
    Information.restaurantId = data["restaurant_id"] ?? "?";
    Information.orderCount = data["total_order"] ?? 0;
    Information.priceCount = (data["total_price"] ?? 0.0).toDouble();
    Information.phone = phone;

    DocumentSnapshot<Map<String, dynamic>> restaurantDocs = await firestore
        .collection('restaurants')
        .doc(Information.restaurantId)
        .get();

    if (!restaurantDocs.exists) return;

    var restaurantData = restaurantDocs.data() as Map<String, dynamic>;
    Information.restaurant = RestaurantModel.fromMap(
        restaurantDocs.id, restaurantData, await _loadMenu());
  }

  static Future<bool> deleteOrder(OrderModel order) async {
    await firestore.collection('pending').doc(order.id).delete();
    return true;
  }

  static Future<bool> createOrderWithoutItems(
      String userId, double totalPrice, double usedBalance) async {
    try {
      await firestore.collection('orders').add({
        'restaurant_id': Information.restaurant?.id,
        'user_id': userId,
        'total_price': totalPrice,
        'used_balance': usedBalance,
        'created_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('activities')
          .add({
        'title': "${Information.restaurant!.name} siparişi",
        'type': "order",
        'amount': totalPrice,
        'date': Timestamp.now(),
      });

      increaseEmployeeStats(totalPrice);

      return true;
    } catch (e) {
      print("Sipariş oluşturulurken hata oluştu: $e");
      return false;
    }
  }

  static Future<void> increaseEmployeeStats(double totalPrice) async {
    Information.orderCount++;
    Information.priceCount += totalPrice;

    var query = await FirebaseFirestore.instance
        .collection("employees")
        .where("phone", isEqualTo: Information.phone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      var employeeDoc = query.docs.first.reference;

      await employeeDoc.update({
        "total_order": FieldValue.increment(1),
        "total_price": FieldValue.increment(totalPrice),
      });
    }
  }

  static Future<bool> createOrder(OrderModel order) async {
    try {
      DocumentReference orderRef = await firestore.collection('orders').add({
        'restaurant_id': order.restaurantId,
        'user_id': order.userId,
        'total_price': order.totalPrice,
        'used_balance': order.usedBalance,
        'created_at': FieldValue.serverTimestamp(),
      });

      String orderId = orderRef.id;
      for (OrderItemModel item in order.items) {
        await orderRef.collection('items').add({
          'id': item.id,
          'unit_price': item.unitPrice,
          'amount': item.amount,
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(order.userId)
          .collection('activities')
          .add({
        'title': "${Information.restaurant!.name} siparişi",
        'type': "order",
        'amount': order.totalPrice,
        'date': Timestamp.now(),
      });

      increaseEmployeeStats(order.totalPrice);
      await firestore.collection('pending').doc(order.id).delete();

      order.id = orderId;
      order.date = Timestamp.now();
      Information.orders.add(order);

      print("Yeni sipariş oluşturuldu! ID: $orderId");
      return true;
    } catch (e) {
      print("Sipariş oluşturulurken hata oluştu: $e");
      return false;
    }
  }

  static Future<void> endOrder(OrderModel order) async {
    Information.orders.removeWhere((model) => model.id == order.id);
  }

  static Future<UserModel?> getUserById(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore
          .instance
          .collection("users")
          .where("user_id", isEqualTo: userId)
          .limit(1)
          .get();

      var userDoc = query.docs;

      if (userDoc.isNotEmpty) {
        var data = userDoc.first.data();
        return UserModel.fromMap(data, userId);
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Kullanıcı bilgisi alınırken hata oluştu: $e");
      return null;
    }
  }

  static Future<OrderModel?> getPendingOrderById(String docId) async {
    try {
      var query = await FirebaseFirestore.instance
          .collection("pending")
          .where("order_id", isEqualTo: docId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      var orderDoc = query.docs.first; // Direkt alıyoruz.
      OrderModel order = OrderModel.fromMap(orderDoc.id, orderDoc.data());

      if (order.restaurantId.isEmpty ||
          order.restaurantId != Information.restaurantId) {
        return null;
      }

      // 🛑 Gereksiz sorgu yerine, doğrudan Firestore'dan koleksiyonu çekiyoruz.
      var itemsSnapshot = await orderDoc.reference.collection("items").get();

      order.items = itemsSnapshot.docs
          .map((doc) => OrderItemModel.fromMap(doc.data()))
          .toList();

      // Kullanıcıyı getiriyoruz
      var userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(order.userId)
          .get();

      if (userDoc.exists) {
        order.userModel = UserModel.fromMap(userDoc.data()!, order.userId);
      }

      return order;
    } catch (e) {
      print("❌ Sipariş getirilirken hata oluştu: $e");
      return null;
    }
  }

  static Future<List<MenuItemModel>> _loadMenu() async {
    try {
      QuerySnapshot menuDocs = await firestore
          .collection('restaurants')
          .doc(Information.restaurantId)
          .collection('menu')
          .get();

      return menuDocs.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return MenuItemModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print("❌ Menüyü yüklerken hata oluştu (: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getEmployeeByPhone(String phone) async {
    var query = await FirebaseFirestore.instance
        .collection("employees")
        .where("phone", isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    } else {
      return null;
    }
  }
}
