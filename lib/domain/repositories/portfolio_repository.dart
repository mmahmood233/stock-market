import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/portfolio_stock.dart';
import '../entities/transaction.dart';

/// Contract for Wallet and trading data.
///
/// [PortfolioBloc] calls this repository when the user opens Wallet, buys,
/// sells, or views transaction history.
abstract class PortfolioRepository {
  /// Returns all holdings owned by a user.
  Future<Either<Failure, List<PortfolioStock>>> getPortfolio(String userId);

  /// Returns one holding when the app needs quantity for a selected symbol.
  Future<Either<Failure, PortfolioStock?>> getPortfolioStock({
    required String userId,
    required String symbol,
  });

  /// Adds shares to the Wallet and creates a buy transaction.
  Future<Either<Failure, Transaction>> buyStock({
    required String userId,
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  });

  /// Removes shares from the Wallet and creates a sell transaction.
  Future<Either<Failure, Transaction>> sellStock({
    required String userId,
    required String symbol,
    required int quantity,
    required double price,
  });

  /// Returns all saved buy and sell records for a user.
  Future<Either<Failure, List<Transaction>>> getTransactionHistory(
    String userId,
  );

  /// Updates a held stock with the latest live market price.
  Future<Either<Failure, void>> updatePortfolioStockPrice({
    required String userId,
    required String symbol,
    required double newPrice,
  });
}
