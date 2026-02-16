import 'package:equatable/equatable.dart';

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

  double get totalInvestment => quantity * averageBuyPrice;
  
  double get currentValue => quantity * currentPrice;
  
  double get profitLoss => currentValue - totalInvestment;
  
  double get profitLossPercentage => 
      totalInvestment > 0 ? (profitLoss / totalInvestment) * 100 : 0;
  
  bool get isProfit => profitLoss >= 0;

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
