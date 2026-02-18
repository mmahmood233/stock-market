import 'package:equatable/equatable.dart';

abstract class StockHistoryEvent extends Equatable {
  const StockHistoryEvent();

  @override
  List<Object?> get props => [];
}

class StockHistoryRequested extends StockHistoryEvent {
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
