import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_model.dart';

/// Local cache contract for the latest stock list.
///
/// [StockRepositoryImpl] writes every successful live update here so the Market
/// page can still show recent data if the server disconnects.
abstract class StockLocalDataSource {
  /// Saves the latest list of live stocks.
  Future<void> cacheStocks(List<StockModel> stocks);

  /// Reads cached stocks if the cache has not expired.
  Future<List<StockModel>> getCachedStocks();

  /// Removes cached stocks and timestamp.
  Future<void> clearCache();
}

/// SharedPreferences implementation of [StockLocalDataSource].
class StockLocalDataSourceImpl implements StockLocalDataSource {
  static const String _cachedStocksKey = 'cached_stocks';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  final SharedPreferences sharedPreferences;

  StockLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheStocks(List<StockModel> stocks) async {
    final stocksJson = stocks.map((stock) => stock.toJson()).toList();
    await sharedPreferences.setString(
      _cachedStocksKey,
      json.encode(stocksJson),
    );
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
