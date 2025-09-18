class UserModel {
  final String id;
  final String name;
  final String surname;
  final double userBalance;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.userBalance,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      userBalance: (data['current_balance'] ?? 0).toDouble(),
      name: data['name'] ?? '',
      surname: data['surname'] ?? 0,
    );
  }
}
