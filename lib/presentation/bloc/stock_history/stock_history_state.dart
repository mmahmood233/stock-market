import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_history.dart';

abstract class StockHistoryState extends Equatable {
  const StockHistoryState();

  @override
  List<Object?> get props => [];
}

class StockHistoryInitial extends StockHistoryState {
  const StockHistoryInitial();
}

class StockHistoryLoading extends StockHistoryState {
  const StockHistoryLoading();
}

class StockHistoryLoaded extends StockHistoryState {
  final String symbol;
  final List<StockHistory> history;

  const StockHistoryLoaded({
    required this.symbol,
    required this.history,
  });

  @override
  List<Object?> get props => [symbol, history];
}

class StockHistoryError extends StockHistoryState {
  final String message;

  const StockHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
