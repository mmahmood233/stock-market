import 'package:equatable/equatable.dart';

/// One historical price point for a stock chart.
///
/// [StockHistoryBloc] sends a list of these to [StockChart], which displays
/// day, week, month, year, and all-time slices.
class StockHistory extends Equatable {
  final String symbol;
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const StockHistory({
    required this.symbol,
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  @override
  List<Object?> get props => [
    symbol,
    timestamp,
    open,
    high,
    low,
    close,
    volume,
  ];
}
