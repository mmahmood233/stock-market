import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_history.dart';

/// Base class for chart states rendered by [StockDetailPage].
abstract class StockHistoryState extends Equatable {
  const StockHistoryState();

  @override
  List<Object?> get props => [];
}

/// No chart request has started yet.
class StockHistoryInitial extends StockHistoryState {
  const StockHistoryInitial();
}

/// Stock Detail should show a chart loading spinner.
class StockHistoryLoading extends StockHistoryState {
  const StockHistoryLoading();
}

/// Chart data is ready for [symbol].
class StockHistoryLoaded extends StockHistoryState {
  final String symbol;
  final List<StockHistory> history;

  const StockHistoryLoaded({required this.symbol, required this.history});

  @override
  List<Object?> get props => [symbol, history];
}

/// Chart loading failed and the UI should show [message].
class StockHistoryError extends StockHistoryState {
  final String message;

  const StockHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
