class AppConstants {
  static const String appName = 'Stock Market';
  
  static const double initialBalance = 1000000.0;
  
  static const int stockUpdateFrequency = 200;
  
  static const int numberOfStocksToMonitor = 20;
  
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
  
  static const String baseUrl = 'ws://localhost:8080';
}
