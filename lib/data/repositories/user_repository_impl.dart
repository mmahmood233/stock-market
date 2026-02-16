import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure('Email and password are required'));
      }

      if (!_isValidEmail(email)) {
        return const Left(ValidationFailure('Invalid email format'));
      }

      final user = await localDataSource.login(email: email, password: password);
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthenticationFailure('Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return const Left(ValidationFailure('All fields are required'));
      }

      if (!_isValidEmail(email)) {
        return const Left(ValidationFailure('Invalid email format'));
      }

      if (password.length < 6) {
        return const Left(ValidationFailure('Password must be at least 6 characters'));
      }

      final user = await localDataSource.signup(
        email: email,
        password: password,
        name: name,
      );
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthenticationFailure('Signup failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure('Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthenticationFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateBalance(double newBalance) async {
    try {
      if (newBalance < 0) {
        return const Left(ValidationFailure('Balance cannot be negative'));
      }

      final user = await localDataSource.updateBalance(newBalance);
      return Right(user.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to update balance: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final loggedIn = await localDataSource.isLoggedIn();
      return Right(loggedIn);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status: $e'));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
