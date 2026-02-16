import 'package:equatable/equatable.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object?> get props => [];
}

class PortfolioLoadRequested extends PortfolioEvent {
  final String userId;

  const PortfolioLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

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

class PortfolioUpdatePrices extends PortfolioEvent {
  final String userId;
  final Map<String, double> prices;

  const PortfolioUpdatePrices({
    required this.userId,
    required this.prices,
  });

  @override
  List<Object?> get props => [userId, prices];
}

class PortfolioTransactionHistoryRequested extends PortfolioEvent {
  final String userId;

  const PortfolioTransactionHistoryRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class PortfolioRefreshRequested extends PortfolioEvent {
  final String userId;

  const PortfolioRefreshRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
