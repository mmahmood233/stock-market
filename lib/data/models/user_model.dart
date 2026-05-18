import '../../domain/entities/user.dart';

/// Storage-ready version of [User].
///
/// [UserLocalDataSourceImpl] converts this model to and from JSON when saving
/// users in SharedPreferences.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.balance,
    required super.createdAt,
  });

  /// Builds a user model from saved JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts this user to JSON for SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converts a domain [User] into a data model.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      balance: user.balance,
      createdAt: user.createdAt,
    );
  }

  /// Returns this model as the domain entity used by BLoCs.
  User toEntity() => this;

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    double? balance,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
