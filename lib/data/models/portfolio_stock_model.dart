import '../../domain/entities/portfolio_stock.dart';

/// Storage-ready version of a Wallet holding.
///
/// [PortfolioLocalDataSourceImpl] saves this model in SharedPreferences after
/// buy, sell, and live price update operations.
class PortfolioStockModel extends PortfolioStock {
  const PortfolioStockModel({
    required super.symbol,
    required super.name,
    required super.quantity,
    required super.averageBuyPrice,
    required super.currentPrice,
    required super.lastUpdated,
  });

  /// Builds a holding from saved JSON.
  factory PortfolioStockModel.fromJson(Map<String, dynamic> json) {
    return PortfolioStockModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Converts this holding to JSON for SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'averageBuyPrice': averageBuyPrice,
      'currentPrice': currentPrice,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Converts a domain [PortfolioStock] into a data model.
  factory PortfolioStockModel.fromEntity(PortfolioStock stock) {
    return PortfolioStockModel(
      symbol: stock.symbol,
      name: stock.name,
      quantity: stock.quantity,
      averageBuyPrice: stock.averageBuyPrice,
      currentPrice: stock.currentPrice,
      lastUpdated: stock.lastUpdated,
    );
  }

  /// Returns this model as the domain entity used by Wallet UI.
  PortfolioStock toEntity() => this;

  /// Creates an updated holding, used when quantity or live price changes.
  @override
  PortfolioStockModel copyWith({
    String? symbol,
    String? name,
    int? quantity,
    double? averageBuyPrice,
    double? currentPrice,
    DateTime? lastUpdated,
  }) {
    return PortfolioStockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
