import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/constants/app_constants.dart';
import '../models/stock_model.dart';
import '../models/stock_history_model.dart';

abstract class StockRemoteDataSource {
  Stream<List<StockModel>> getRealtimeStocks();
  Future<List<StockHistoryModel>> getStockHistory({
    required String symbol,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<StockModel> getStockBySymbol(String symbol);
  void dispose();
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  WebSocketChannel? _channel;
  StreamController<List<StockModel>>? _stockController;

  @override
  Stream<List<StockModel>> getRealtimeStocks() {
    _stockController = StreamController<List<StockModel>>.broadcast();
    
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(AppConstants.baseUrl),
      );

      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = json.decode(data as String);
            
            if (jsonData is List) {
              final stocks = jsonData
                  .map((item) => StockModel.fromJson(item as Map<String, dynamic>))
                  .toList();
              _stockController!.add(stocks);
            } else if (jsonData is Map<String, dynamic>) {
              final stock = StockModel.fromJson(jsonData);
              _stockController!.add([stock]);
            }
          } catch (e) {
            _stockController!.addError(Exception('Failed to parse stock data: $e'));
          }
        },
        onError: (error) {
          _stockController!.addError(Exception('WebSocket error: $error'));
        },
        onDone: () {
          _stockController!.close();
        },
      );
    } catch (e) {
      _stockController!.addError(Exception('Failed to connect to WebSocket: $e'));
    }

    return _stockController!.stream;
  }

  @override
  Future<List<StockHistoryModel>> getStockHistory({
    required String symbol,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final history = <StockHistoryModel>[];
    final days = endDate.difference(startDate).inDays;
    
    double basePrice = 100.0 + (symbol.hashCode % 500);
    
    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final random = (date.millisecondsSinceEpoch % 100) / 100;
      final change = (random - 0.5) * 10;
      
      basePrice = (basePrice + change).clamp(10.0, 10000.0);
      
      final open = basePrice;
      final close = basePrice + ((random - 0.5) * 5);
      final high = [open, close].reduce((a, b) => a > b ? a : b) + (random * 3);
      final low = [open, close].reduce((a, b) => a < b ? a : b) - (random * 3);
      
      history.add(StockHistoryModel(
        symbol: symbol,
        timestamp: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 1000000 + (random * 5000000),
      ));
    }
    
    return history;
  }

  @override
  Future<StockModel> getStockBySymbol(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final price = 100.0 + (symbol.hashCode % 500).toDouble();
    final previousClose = price - ((symbol.hashCode % 10) - 5);
    
    return StockModel(
      symbol: symbol,
      name: _getStockName(symbol),
      currentPrice: price,
      previousClose: previousClose,
      changeAmount: price - previousClose,
      changePercentage: ((price - previousClose) / previousClose) * 100,
      dayHigh: price + 5,
      dayLow: price - 5,
      volume: 1000000.0,
      lastUpdated: DateTime.now(),
    );
  }

  String _getStockName(String symbol) {
    const stockNames = {
      'AAPL': 'Apple Inc.',
      'GOOGL': 'Alphabet Inc.',
      'MSFT': 'Microsoft Corporation',
      'AMZN': 'Amazon.com Inc.',
      'TSLA': 'Tesla Inc.',
      'META': 'Meta Platforms Inc.',
      'NVDA': 'NVIDIA Corporation',
      'NFLX': 'Netflix Inc.',
      'AMD': 'Advanced Micro Devices',
      'INTC': 'Intel Corporation',
      'ORCL': 'Oracle Corporation',
      'IBM': 'IBM Corporation',
      'CSCO': 'Cisco Systems',
      'ADBE': 'Adobe Inc.',
      'CRM': 'Salesforce Inc.',
      'PYPL': 'PayPal Holdings',
      'UBER': 'Uber Technologies',
      'LYFT': 'Lyft Inc.',
      'SNAP': 'Snap Inc.',
      'SPOT': 'Spotify Technology',
    };
    return stockNames[symbol] ?? symbol;
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _stockController?.close();
  }
}
