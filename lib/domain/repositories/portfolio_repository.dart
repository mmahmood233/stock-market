import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/portfolio_stock.dart';
import '../entities/transaction.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, List<PortfolioStock>>> getPortfolio(String userId);
  
  Future<Either<Failure, PortfolioStock?>> getPortfolioStock({
    required String userId,
    required String symbol,
  });
  
  Future<Either<Failure, Transaction>> buyStock({
    required String userId,
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  });
  
  Future<Either<Failure, Transaction>> sellStock({
    required String userId,
    required String symbol,
    required int quantity,
    required double price,
  });
  
  Future<Either<Failure, List<Transaction>>> getTransactionHistory(String userId);
  
  Future<Either<Failure, void>> updatePortfolioStockPrice({
    required String userId,
    required String symbol,
    required double newPrice,
  });
}
