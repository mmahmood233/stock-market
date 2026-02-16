import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_model.dart';

abstract class StockLocalDataSource {
  Future<void> cacheStocks(List<StockModel> stocks);
  Future<List<StockModel>> getCachedStocks();
  Future<void> clearCache();
}

class StockLocalDataSourceImpl implements StockLocalDataSource {
  static const String _cachedStocksKey = 'cached_stocks';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  final SharedPreferences sharedPreferences;

  StockLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheStocks(List<StockModel> stocks) async {
    final stocksJson = stocks.map((stock) => stock.toJson()).toList();
    await sharedPreferences.setString(_cachedStocksKey, json.encode(stocksJson));
    await sharedPreferences.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<StockModel>> getCachedStocks() async {
    final cachedTimestamp = sharedPreferences.getInt(_cacheTimestampKey);
    
    if (cachedTimestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheValidDuration) {
        await clearCache();
        throw Exception('Cache expired');
      }
    }

    final cachedString = sharedPreferences.getString(_cachedStocksKey);
    if (cachedString == null) {
      throw Exception('No cached stocks found');
    }

    final List<dynamic> stocksJson = json.decode(cachedString);
    return stocksJson
        .map((json) => StockModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedStocksKey);
    await sharedPreferences.remove(_cacheTimestampKey);
  }
}
