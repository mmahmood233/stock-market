import 'package:equatable/equatable.dart';

/// One stock owned by a user in the Wallet.
///
/// [PortfolioRepository] returns this entity to [PortfolioBloc]. Wallet cards
/// use it to show quantity, value, and profit/loss.
class PortfolioStock extends Equatable {
  final String symbol;
  final String name;
  final int quantity;
  final double averageBuyPrice;
  final double currentPrice;
  final DateTime lastUpdated;

  const PortfolioStock({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentPrice,
    required this.lastUpdated,
  });

  /// Money spent to buy the currently held quantity.
  double get totalInvestment => quantity * averageBuyPrice;

  /// Current market value based on the latest live price.
  double get currentValue => quantity * currentPrice;

  /// Difference between current value and money invested.
  double get profitLoss => currentValue - totalInvestment;

  /// Profit or loss as a percentage of the original investment.
  double get profitLossPercentage =>
      totalInvestment > 0 ? (profitLoss / totalInvestment) * 100 : 0;

  /// True when the holding is not losing money.
  bool get isProfit => profitLoss >= 0;

  /// Creates an updated holding without mutating the old one.
  PortfolioStock copyWith({
    String? symbol,
    String? name,
    int? quantity,
    double? averageBuyPrice,
    double? currentPrice,
    DateTime? lastUpdated,
  }) {
    return PortfolioStock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    name,
    quantity,
    averageBuyPrice,
    currentPrice,
    lastUpdated,
  ];
}
