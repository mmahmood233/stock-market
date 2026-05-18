import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// Base class for authentication states rendered by auth and home pages.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the app checks saved login status.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Shown while login, signup, logout, or balance update is running.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is logged in.
///
/// [HomePage], [TradeDialog], and [PortfolioPage] read the [user] from here.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not logged in and should see [LoginPage].
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication failed and the UI should show [message].
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
