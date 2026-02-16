import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/stock.dart';
import '../../domain/entities/stock_history.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';
import '../datasources/stock_remote_datasource.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;
  final StockLocalDataSource localDataSource;

  StockRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<Either<Failure, List<Stock>>> getRealtimeStocks() async* {
    try {
      await for (final stocks in remoteDataSource.getRealtimeStocks()) {
        await localDataSource.cacheStocks(stocks);
        yield Right(stocks.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      try {
        final cachedStocks = await localDataSource.getCachedStocks();
        yield Right(cachedStocks.map((model) => model.toEntity()).toList());
      } catch (cacheError) {
        yield Left(NetworkFailure('Failed to fetch stocks: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<StockHistory>>> getStockHistory({
    required String symbol,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final history = await remoteDataSource.getStockHistory(
        symbol: symbol,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(history.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to fetch stock history: $e'));
    }
  }

  @override
  Future<Either<Failure, Stock>> getStockBySymbol(String symbol) async {
    try {
      final stock = await remoteDataSource.getStockBySymbol(symbol);
      return Right(stock.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to fetch stock: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Stock>>> getCachedStocks() async {
    try {
      final cachedStocks = await localDataSource.getCachedStocks();
      return Right(cachedStocks.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('No cached stocks available: $e'));
    }
  }
}
