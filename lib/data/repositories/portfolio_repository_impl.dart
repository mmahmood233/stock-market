import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/portfolio_stock.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioLocalDataSource localDataSource;

  PortfolioRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PortfolioStock>>> getPortfolio(String userId) async {
    try {
      final portfolio = await localDataSource.getPortfolio(userId);
      return Right(portfolio.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get portfolio: $e'));
    }
  }

  @override
  Future<Either<Failure, PortfolioStock?>> getPortfolioStock({
    required String userId,
    required String symbol,
  }) async {
    try {
      final stock = await localDataSource.getPortfolioStock(
        userId: userId,
        symbol: symbol,
      );
      return Right(stock?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get portfolio stock: $e'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> buyStock({
    required String userId,
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  }) async {
    try {
      if (quantity <= 0) {
        return const Left(ValidationFailure('Quantity must be greater than 0'));
      }

      if (price <= 0) {
        return const Left(ValidationFailure('Price must be greater than 0'));
      }

      final transaction = await localDataSource.buyStock(
        userId: userId,
        symbol: symbol,
        name: name,
        quantity: quantity,
        price: price,
      );
      return Right(transaction.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to buy stock: $e'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> sellStock({
    required String userId,
    required String symbol,
    required int quantity,
    required double price,
  }) async {
    try {
      if (quantity <= 0) {
        return const Left(ValidationFailure('Quantity must be greater than 0'));
      }

      if (price <= 0) {
        return const Left(ValidationFailure('Price must be greater than 0'));
      }

      final transaction = await localDataSource.sellStock(
        userId: userId,
        symbol: symbol,
        quantity: quantity,
        price: price,
      );
      return Right(transaction.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to sell stock: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionHistory(String userId) async {
    try {
      final transactions = await localDataSource.getTransactionHistory(userId);
      return Right(transactions.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get transaction history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePortfolioStockPrice({
    required String userId,
    required String symbol,
    required double newPrice,
  }) async {
    try {
      await localDataSource.updatePortfolioStockPrice(
        userId: userId,
        symbol: symbol,
        newPrice: newPrice,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update stock price: $e'));
    }
  }
}
