import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Contract for user authentication and balance changes.
///
/// [AuthBloc] depends on this abstract class, not the local data source. This
/// keeps authentication logic separate from storage details.
abstract class UserRepository {
  /// Validates credentials and returns the saved user.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Creates a new user with the starting fake balance.
  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
    required String name,
  });

  /// Clears the current session.
  Future<Either<Failure, void>> logout();

  /// Returns the logged-in user saved in the session.
  Future<Either<Failure, User>> getCurrentUser();

  /// Saves a new balance after a buy or sell.
  Future<Either<Failure, User>> updateBalance(double newBalance);

  /// Used by [SplashPage] to decide whether to show home or login.
  Future<Either<Failure, bool>> isLoggedIn();
}
