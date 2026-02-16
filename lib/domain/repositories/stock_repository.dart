import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/stock.dart';
import '../entities/stock_history.dart';

abstract class StockRepository {
  Stream<Either<Failure, List<Stock>>> getRealtimeStocks();
  
  Future<Either<Failure, List<StockHistory>>> getStockHistory({
    required String symbol,
    required DateTime startDate,
    required DateTime endDate,
  });
  
  Future<Either<Failure, Stock>> getStockBySymbol(String symbol);
  
  Future<Either<Failure, List<Stock>>> getCachedStocks();
}
