import 'package:equatable/equatable.dart';

/// Base class for Wallet and trading actions sent to [PortfolioBloc].
abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the current user's Wallet holdings.
class PortfolioLoadRequested extends PortfolioEvent {
  final String userId;

  const PortfolioLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Sent by [TradeDialog] after the user confirms a buy order.
class PortfolioBuyStock extends PortfolioEvent {
  final String userId;
  final String symbol;
  final String name;
  final int quantity;
  final double price;

  const PortfolioBuyStock({
    required this.userId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [userId, symbol, name, quantity, price];
}

/// Sent by [TradeDialog] after the user confirms a sell order.
class PortfolioSellStock extends PortfolioEvent {
  final String userId;
  final String symbol;
  final int quantity;
  final double price;

  const PortfolioSellStock({
    required this.userId,
    required this.symbol,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [userId, symbol, quantity, price];
}

/// Updates held stock prices using the latest live prices.
class PortfolioUpdatePrices extends PortfolioEvent {
  final String userId;
  final Map<String, double> prices;

  const PortfolioUpdatePrices({required this.userId, required this.prices});

  @override
  List<Object?> get props => [userId, prices];
}

/// Loads the user's transaction history page.
class PortfolioTransactionHistoryRequested extends PortfolioEvent {
  final String userId;

  const PortfolioTransactionHistoryRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Reloads the Wallet after pull-to-refresh or a completed trade.
class PortfolioRefreshRequested extends PortfolioEvent {
  final String userId;

  const PortfolioRefreshRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
