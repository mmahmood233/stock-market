import '../../domain/entities/portfolio_stock.dart';

class PortfolioStockModel extends PortfolioStock {
  const PortfolioStockModel({
    required super.symbol,
    required super.name,
    required super.quantity,
    required super.averageBuyPrice,
    required super.currentPrice,
    required super.lastUpdated,
  });

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

  PortfolioStock toEntity() => this;

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
