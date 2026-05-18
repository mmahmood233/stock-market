import '../../domain/entities/stock_history.dart';

/// Data model for chart history points.
///
/// [StockRemoteDataSourceImpl] creates these generated history records, and
/// [StockHistoryBloc] sends them to [StockChart].
class StockHistoryModel extends StockHistory {
  const StockHistoryModel({
    required super.symbol,
    required super.timestamp,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
  });

  /// Builds a history point from JSON.
  factory StockHistoryModel.fromJson(Map<String, dynamic> json) {
    return StockHistoryModel(
      symbol: json['symbol'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }

  /// Converts this history point to JSON if caching is needed later.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  /// Converts a domain [StockHistory] into a data model.
  factory StockHistoryModel.fromEntity(StockHistory history) {
    return StockHistoryModel(
      symbol: history.symbol,
      timestamp: history.timestamp,
      open: history.open,
      high: history.high,
      low: history.low,
      close: history.close,
      volume: history.volume,
    );
  }

  /// Returns this model as the domain entity used by the chart widget.
  StockHistory toEntity() => this;
}
