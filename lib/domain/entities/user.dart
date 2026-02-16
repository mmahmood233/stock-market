import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final double balance;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.balance,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    double? balance,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, balance, createdAt];
}
