class OrderItemModel {
  final String id;
  final int amount;
  final double unitPrice;

  OrderItemModel({
    required this.id,
    required this.unitPrice,
    required this.amount,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      id: data['id'] ?? '',
      unitPrice: (data['unit_price'] ?? 0).toDouble(),
      amount: data['amount'] ?? 0,
    );
  }
}
