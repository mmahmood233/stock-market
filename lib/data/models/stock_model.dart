import '../../domain/entities/stock.dart';

/// Data model for live stock updates from the mock WebSocket server.
///
/// [StockRemoteDataSourceImpl] parses server JSON into this model, then
/// [StockRepositoryImpl] exposes it as a [Stock] entity.
class StockModel extends Stock {
  const StockModel({
    required super.symbol,
    required super.name,
    required super.currentPrice,
    required super.previousClose,
    required super.changeAmount,
    required super.changePercentage,
    required super.dayHigh,
    required super.dayLow,
    required super.volume,
    required super.lastUpdated,
  });

  /// Builds a stock from the server JSON payload.
  factory StockModel.fromJson(Map<String, dynamic> json) {
    final currentPrice = (json['price'] as num).toDouble();
    final previousClose =
        (json['previousClose'] as num?)?.toDouble() ?? currentPrice;
    final changeAmount = currentPrice - previousClose;
    final changePercentage = previousClose > 0
        ? (changeAmount / previousClose) * 100
        : 0.0;

    return StockModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String? ?? json['symbol'] as String,
      currentPrice: currentPrice,
      previousClose: previousClose,
      changeAmount: changeAmount,
      changePercentage: changePercentage,
      dayHigh: (json['dayHigh'] as num?)?.toDouble() ?? currentPrice,
      dayLow: (json['dayLow'] as num?)?.toDouble() ?? currentPrice,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this stock to JSON for local cache storage.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': currentPrice,
      'previousClose': previousClose,
      'dayHigh': dayHigh,
      'dayLow': dayLow,
      'volume': volume,
      'timestamp': lastUpdated.toIso8601String(),
    };
  }

  /// Converts a domain [Stock] back into a cacheable model.
  factory StockModel.fromEntity(Stock stock) {
    return StockModel(
      symbol: stock.symbol,
      name: stock.name,
      currentPrice: stock.currentPrice,
      previousClose: stock.previousClose,
      changeAmount: stock.changeAmount,
      changePercentage: stock.changePercentage,
      dayHigh: stock.dayHigh,
      dayLow: stock.dayLow,
      volume: stock.volume,
      lastUpdated: stock.lastUpdated,
    );
  }

  /// Returns this model as the domain entity used by the UI.
  Stock toEntity() => this;
}
