import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class StockLoadRequested extends StockEvent {
  const StockLoadRequested();
}

class StockRealtimeStarted extends StockEvent {
  const StockRealtimeStarted();
}

class StockRealtimeStopped extends StockEvent {
  const StockRealtimeStopped();
}

class StockHistoryRequested extends StockEvent {
  final String symbol;
  final DateTime startDate;
  final DateTime endDate;

  const StockHistoryRequested({
    required this.symbol,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [symbol, startDate, endDate];
}

class StockRefreshRequested extends StockEvent {
  const StockRefreshRequested();
}
