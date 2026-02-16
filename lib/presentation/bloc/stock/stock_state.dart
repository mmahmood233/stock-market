import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/stock_history.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {
  const StockInitial();
}

class StockLoading extends StockState {
  const StockLoading();
}

class StockLoaded extends StockState {
  final List<Stock> stocks;
  final bool isRealtime;

  const StockLoaded({
    required this.stocks,
    this.isRealtime = false,
  });

  @override
  List<Object?> get props => [stocks, isRealtime];

  StockLoaded copyWith({
    List<Stock>? stocks,
    bool? isRealtime,
  }) {
    return StockLoaded(
      stocks: stocks ?? this.stocks,
      isRealtime: isRealtime ?? this.isRealtime,
    );
  }
}

class StockHistoryLoaded extends StockState {
  final String symbol;
  final List<StockHistory> history;

  const StockHistoryLoaded({
    required this.symbol,
    required this.history,
  });

  @override
  List<Object?> get props => [symbol, history];
}

class StockError extends StockState {
  final String message;
  final List<Stock>? cachedStocks;

  const StockError(this.message, {this.cachedStocks});

  @override
  List<Object?> get props => [message, cachedStocks];
}

class StockEmpty extends StockState {
  const StockEmpty();
}
