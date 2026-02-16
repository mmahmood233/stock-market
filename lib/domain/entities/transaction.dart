import 'package:equatable/equatable.dart';

enum TransactionType { buy, sell }

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

  bool get isBuy => type == TransactionType.buy;
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
