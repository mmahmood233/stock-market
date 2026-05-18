import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock.dart';

/// Base class for stock list states rendered by [MarketPage].
abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

/// No stock request has started yet.
class StockInitial extends StockState {
  const StockInitial();
}

/// Market page should show a loading spinner.
class StockLoading extends StockState {
  const StockLoading();
}

/// Market page should show [stocks].
///
/// [isRealtime] tells the UI whether the list came from the live WebSocket.
class StockLoaded extends StockState {
  final List<Stock> stocks;
  final bool isRealtime;

  const StockLoaded({required this.stocks, this.isRealtime = false});

  @override
  List<Object?> get props => [stocks, isRealtime];

  /// Creates a new state when only some fields change.
  StockLoaded copyWith({List<Stock>? stocks, bool? isRealtime}) {
    return StockLoaded(
      stocks: stocks ?? this.stocks,
      isRealtime: isRealtime ?? this.isRealtime,
    );
  }
}

/// Stock loading failed.
///
/// [cachedStocks] can be used later if the UI wants to offer cached data.
class StockError extends StockState {
  final String message;
  final List<Stock>? cachedStocks;

  const StockError(this.message, {this.cachedStocks});

  @override
  List<Object?> get props => [message, cachedStocks];
}

/// No stocks were returned.
class StockEmpty extends StockState {
  const StockEmpty();
}
