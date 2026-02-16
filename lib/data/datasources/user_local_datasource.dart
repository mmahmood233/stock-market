import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signup({required String email, required String password, required String name});
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateBalance(double newBalance);
  Future<bool> isLoggedIn();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  UserLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.uuid,
  });

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final usersJson = sharedPreferences.getString('users') ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    if (!users.containsKey(email)) {
      throw Exception('User not found');
    }

    final userData = users[email] as Map<String, dynamic>;
    if (userData['password'] != password) {
      throw Exception('Invalid password');
    }

    final user = UserModel.fromJson(userData['user']);

    await sharedPreferences.setBool(StorageKeys.isLoggedIn, true);
    await sharedPreferences.setString(StorageKeys.userId, user.id);
    await sharedPreferences.setString(StorageKeys.userEmail, user.email);
    await sharedPreferences.setString(StorageKeys.userName, user.name);

    return user;
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final usersJson = sharedPreferences.getString('users') ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    if (users.containsKey(email)) {
      throw Exception('User already exists');
    }

    final user = UserModel(
      id: uuid.v4(),
      email: email,
      name: name,
      balance: AppConstants.initialBalance,
      createdAt: DateTime.now(),
    );

    users[email] = {
      'password': password,
      'user': user.toJson(),
    };

    await sharedPreferences.setString('users', json.encode(users));
    await sharedPreferences.setBool(StorageKeys.isLoggedIn, true);
    await sharedPreferences.setString(StorageKeys.userId, user.id);
    await sharedPreferences.setString(StorageKeys.userEmail, user.email);
    await sharedPreferences.setString(StorageKeys.userName, user.name);

    return user;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.setBool(StorageKeys.isLoggedIn, false);
    await sharedPreferences.remove(StorageKeys.userId);
    await sharedPreferences.remove(StorageKeys.userEmail);
    await sharedPreferences.remove(StorageKeys.userName);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final isLoggedIn = sharedPreferences.getBool(StorageKeys.isLoggedIn) ?? false;
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final userId = sharedPreferences.getString(StorageKeys.userId);
    final userEmail = sharedPreferences.getString(StorageKeys.userEmail);

    if (userId == null || userEmail == null) {
      throw Exception('User data not found');
    }

    final usersJson = sharedPreferences.getString('users') ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    if (!users.containsKey(userEmail)) {
      throw Exception('User not found');
    }

    final userData = users[userEmail] as Map<String, dynamic>;
    return UserModel.fromJson(userData['user']);
  }

  @override
  Future<UserModel> updateBalance(double newBalance) async {
    final user = await getCurrentUser();
    final updatedUser = user.copyWith(balance: newBalance);

    final usersJson = sharedPreferences.getString('users') ?? '{}';
    final Map<String, dynamic> users = json.decode(usersJson);

    if (users.containsKey(user.email)) {
      final userData = users[user.email] as Map<String, dynamic>;
      userData['user'] = updatedUser.toJson();
      await sharedPreferences.setString('users', json.encode(users));
    }

    return updatedUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPreferences.getBool(StorageKeys.isLoggedIn) ?? false;
  }
}
