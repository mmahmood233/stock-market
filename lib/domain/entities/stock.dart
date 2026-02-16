import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousClose;
  final double changeAmount;
  final double changePercentage;
  final double dayHigh;
  final double dayLow;
  final double volume;
  final DateTime lastUpdated;

  const Stock({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousClose,
    required this.changeAmount,
    required this.changePercentage,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    required this.lastUpdated,
  });

  bool get isPositive => changeAmount >= 0;

  @override
  List<Object?> get props => [
        symbol,
        name,
        currentPrice,
        previousClose,
        changeAmount,
        changePercentage,
        dayHigh,
        dayLow,
        volume,
        lastUpdated,
      ];
}
