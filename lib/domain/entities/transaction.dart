import 'package:equatable/equatable.dart';

/// Type of trade saved in transaction history.
enum TransactionType { buy, sell }

/// A completed buy or sell order.
///
/// [PortfolioLocalDataSourceImpl] saves this after every trade. The
/// Transaction History page reads it through [PortfolioBloc].
class Transaction extends Equatable {
  final String id;
  final String userId;
  final String stockSymbol;
  final String stockName;
  final TransactionType type;
  final int quantity;
  final double pricePerShare;
  final double totalAmount;
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.userId,
    required this.stockSymbol,
    required this.stockName,
    required this.type,
    required this.quantity,
    required this.pricePerShare,
    required this.totalAmount,
    required this.timestamp,
  });

  /// Used by transaction UI to color and label buy rows.
  bool get isBuy => type == TransactionType.buy;

  /// Used by transaction UI to color and label sell rows.
  bool get isSell => type == TransactionType.sell;

  @override
  List<Object?> get props => [
    id,
    userId,
    stockSymbol,
    stockName,
    type,
    quantity,
    pricePerShare,
    totalAmount,
    timestamp,
  ];
}
