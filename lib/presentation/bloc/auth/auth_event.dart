import 'package:equatable/equatable.dart';

/// Base class for authentication actions sent from the UI to [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Sent by [LoginPage] when the user presses Login.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sent by [SignupPage] when the user creates a new account.
class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Sent by [HomePage] when the user confirms logout.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Sent by [SplashPage] to decide whether to show Home or Login.
class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

/// Sent by [PortfolioBloc] after buy or sell changes the fake cash balance.
class AuthUpdateBalance extends AuthEvent {
  final double newBalance;

  const AuthUpdateBalance(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}
