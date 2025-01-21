import '../../../core/shared/constants/key_names.dart';

class WalletModel {
  final String userId;
  final int balance;
  WalletModel({
    required this.userId,
    required this.balance,
  });

  WalletModel copyWith({
    String? userId,
    int? balance,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.user_id: userId,
      KeyNames.balance: balance,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      userId: map[KeyNames.user_id] ?? "",
      balance: map['balance'] ?? 0,
    );
  }

  @override
  String toString() => 'WalletModel(userId: $userId, balance: $balance)';

  @override
  bool operator ==(covariant WalletModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId && other.balance == balance;
  }

  @override
  int get hashCode => userId.hashCode ^ balance.hashCode;
}
