import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/portfolio_stock_model.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

abstract class PortfolioLocalDataSource {
  Future<List<PortfolioStockModel>> getPortfolio(String userId);
  Future<PortfolioStockModel?> getPortfolioStock({required String userId, required String symbol});
  Future<TransactionModel> buyStock({
    required String userId,
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  });
  Future<TransactionModel> sellStock({
    required String userId,
    required String symbol,
    required int quantity,
    required double price,
  });
  Future<List<TransactionModel>> getTransactionHistory(String userId);
  Future<void> updatePortfolioStockPrice({
    required String userId,
    required String symbol,
    required double newPrice,
  });
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Uuid uuid;

  PortfolioLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.uuid,
  });

  String _getPortfolioKey(String userId) => 'portfolio_$userId';
  String _getTransactionsKey(String userId) => 'transactions_$userId';

  @override
  Future<List<PortfolioStockModel>> getPortfolio(String userId) async {
    final portfolioJson = sharedPreferences.getString(_getPortfolioKey(userId));
    if (portfolioJson == null) return [];

    final List<dynamic> portfolio = json.decode(portfolioJson);
    return portfolio
        .map((json) => PortfolioStockModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PortfolioStockModel?> getPortfolioStock({
    required String userId,
    required String symbol,
  }) async {
    final portfolio = await getPortfolio(userId);
    try {
      return portfolio.firstWhere((stock) => stock.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<TransactionModel> buyStock({
    required String userId,
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  }) async {
    final portfolio = await getPortfolio(userId);
    final existingStock = portfolio.cast<PortfolioStockModel?>().firstWhere(
      (stock) => stock?.symbol == symbol,
      orElse: () => null,
    );

    final totalCost = quantity * price;
    final transaction = TransactionModel(
      id: uuid.v4(),
      userId: userId,
      stockSymbol: symbol,
      stockName: name,
      type: TransactionType.buy,
      quantity: quantity,
      pricePerShare: price,
      totalAmount: totalCost,
      timestamp: DateTime.now(),
    );

    if (existingStock != null) {
      final newQuantity = existingStock.quantity + quantity;
      final newAveragePrice = ((existingStock.averageBuyPrice * existingStock.quantity) + 
          (price * quantity)) / newQuantity;

      final updatedStock = existingStock.copyWith(
        quantity: newQuantity,
        averageBuyPrice: newAveragePrice,
        currentPrice: price,
        lastUpdated: DateTime.now(),
      );

      portfolio.removeWhere((stock) => stock.symbol == symbol);
      portfolio.add(updatedStock);
    } else {
      portfolio.add(PortfolioStockModel(
        symbol: symbol,
        name: name,
        quantity: quantity,
        averageBuyPrice: price,
        currentPrice: price,
        lastUpdated: DateTime.now(),
      ));
    }

    await _savePortfolio(userId, portfolio);
    await _saveTransaction(userId, transaction);

    return transaction;
  }

  @override
  Future<TransactionModel> sellStock({
    required String userId,
    required String symbol,
    required int quantity,
    required double price,
  }) async {
    final portfolio = await getPortfolio(userId);
    final existingStock = portfolio.cast<PortfolioStockModel?>().firstWhere(
      (stock) => stock?.symbol == symbol,
      orElse: () => null,
    );

    if (existingStock == null) {
      throw Exception('Stock not found in portfolio');
    }

    if (existingStock.quantity < quantity) {
      throw Exception('Insufficient quantity to sell');
    }

    final totalRevenue = quantity * price;
    final transaction = TransactionModel(
      id: uuid.v4(),
      userId: userId,
      stockSymbol: symbol,
      stockName: existingStock.name,
      type: TransactionType.sell,
      quantity: quantity,
      pricePerShare: price,
      totalAmount: totalRevenue,
      timestamp: DateTime.now(),
    );

    final newQuantity = existingStock.quantity - quantity;

    portfolio.removeWhere((stock) => stock.symbol == symbol);

    if (newQuantity > 0) {
      final updatedStock = existingStock.copyWith(
        quantity: newQuantity,
        currentPrice: price,
        lastUpdated: DateTime.now(),
      );
      portfolio.add(updatedStock);
    }

    await _savePortfolio(userId, portfolio);
    await _saveTransaction(userId, transaction);

    return transaction;
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory(String userId) async {
    final transactionsJson = sharedPreferences.getString(_getTransactionsKey(userId));
    if (transactionsJson == null) return [];

    final List<dynamic> transactions = json.decode(transactionsJson);
    return transactions
        .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> updatePortfolioStockPrice({
    required String userId,
    required String symbol,
    required double newPrice,
  }) async {
    final portfolio = await getPortfolio(userId);
    final stockIndex = portfolio.indexWhere((stock) => stock.symbol == symbol);

    if (stockIndex != -1) {
      portfolio[stockIndex] = portfolio[stockIndex].copyWith(
        currentPrice: newPrice,
        lastUpdated: DateTime.now(),
      );
      await _savePortfolio(userId, portfolio);
    }
  }

  Future<void> _savePortfolio(String userId, List<PortfolioStockModel> portfolio) async {
    final portfolioJson = portfolio.map((stock) => stock.toJson()).toList();
    await sharedPreferences.setString(_getPortfolioKey(userId), json.encode(portfolioJson));
  }

  Future<void> _saveTransaction(String userId, TransactionModel transaction) async {
    final transactions = await getTransactionHistory(userId);
    transactions.insert(0, transaction);
    
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await sharedPreferences.setString(_getTransactionsKey(userId), json.encode(transactionsJson));
  }
}
