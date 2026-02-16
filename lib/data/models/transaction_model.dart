import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.stockSymbol,
    required super.stockName,
    required super.type,
    required super.quantity,
    required super.pricePerShare,
    required super.totalAmount,
    required super.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stockSymbol: json['stockSymbol'] as String,
      stockName: json['stockName'] as String,
      type: json['type'] == 'buy' ? TransactionType.buy : TransactionType.sell,
      quantity: json['quantity'] as int,
      pricePerShare: (json['pricePerShare'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'stockSymbol': stockSymbol,
      'stockName': stockName,
      'type': type == TransactionType.buy ? 'buy' : 'sell',
      'quantity': quantity,
      'pricePerShare': pricePerShare,
      'totalAmount': totalAmount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      stockSymbol: transaction.stockSymbol,
      stockName: transaction.stockName,
      type: transaction.type,
      quantity: transaction.quantity,
      pricePerShare: transaction.pricePerShare,
      totalAmount: transaction.totalAmount,
      timestamp: transaction.timestamp,
    );
  }

  Transaction toEntity() => this;
}
