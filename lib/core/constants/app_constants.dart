import '../config/stock_server_config.dart';

/// Values that are reused across the app.
///
/// BLoCs, data sources, and UI widgets read from here instead of duplicating
/// numbers like the starting balance or the list of monitored stocks.
class AppConstants {
  /// Shown in the app bar, splash screen, and auth screens.
  static const String appName = 'Stock Market';

  /// Every new signed-up user starts with this fake money amount.
  static const double initialBalance = 1000000.0;

  /// Mock server update interval in milliseconds, equal to 5 updates per second.
  static const int stockUpdateFrequency = 200;

  /// Subject requirement: the app must monitor exactly 20 stocks.
  static const int numberOfStocksToMonitor = 20;

  /// The 20 symbols sent by the mock server and displayed on the Market page.
  static const List<String> monitoredStocks = [
    'AAPL',
    'GOOGL',
    'MSFT',
    'AMZN',
    'TSLA',
    'META',
    'NVDA',
    'NFLX',
    'AMD',
    'INTC',
    'ORCL',
    'IBM',
    'CSCO',
    'ADBE',
    'CRM',
    'PYPL',
    'UBER',
    'LYFT',
    'SNAP',
    'SPOT',
  ];

  /// WebSocket URL used by [StockRemoteDataSourceImpl].
  ///
  /// A custom value can be passed with:
  /// `flutter run --dart-define=STOCK_WS_URL=ws://HOST:8080`.
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('STOCK_WS_URL');
    return configuredUrl.isNotEmpty ? configuredUrl : defaultStockServerUrl;
  }
}
