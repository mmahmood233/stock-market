import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/stock.dart';
import '../entities/stock_history.dart';

/// Contract for stock market data.
///
/// [StockBloc] uses live prices from this repository. [StockHistoryBloc] uses
/// historical data from the same contract for charts.
abstract class StockRepository {
  /// Streams real-time stock updates from the mock WebSocket server.
  Stream<Either<Failure, List<Stock>>> getRealtimeStocks();

  /// Returns chart data for a selected stock and date range.
  Future<Either<Failure, List<StockHistory>>> getStockHistory({
    required String symbol,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Returns one stock by symbol when a screen needs a fallback lookup.
  Future<Either<Failure, Stock>> getStockBySymbol(String symbol);

  /// Returns the last cached live stock list when the server is unavailable.
  Future<Either<Failure, List<Stock>>> getCachedStocks();
}
