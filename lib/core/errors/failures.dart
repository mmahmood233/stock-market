import 'package:equatable/equatable.dart';

/// Base class for expected app errors.
///
/// Repositories return [Failure] objects to BLoCs so the UI can show clean
/// messages instead of raw exceptions.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Used when generated or remote historical data fails.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Used when the WebSocket connection to the mock stock server fails.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Used when SharedPreferences cache reads or writes fail.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Used by login, signup, logout, and current-user checks.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Used when user input or trade data is not valid.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
