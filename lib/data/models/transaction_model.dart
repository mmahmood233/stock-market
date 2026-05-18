import '../../domain/entities/transaction.dart';

/// Storage-ready version of a trade transaction.
///
/// [PortfolioLocalDataSourceImpl] saves this after buy or sell, and the
/// Transaction History page reads it through [PortfolioBloc].
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

  /// Builds a transaction from saved JSON.
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

  /// Converts this transaction to JSON for SharedPreferences.
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

  /// Converts a domain [Transaction] into a data model.
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

  /// Returns this model as the domain entity used by the UI.
  Transaction toEntity() => this;
}
