import 'dart:io' show Platform;

/// Default WebSocket URL for mobile and desktop builds.
///
/// Android emulators cannot reach the host machine through `localhost`, so they
/// use `10.0.2.2`. iOS simulator, desktop, and tests can use `localhost`.
String get defaultStockServerUrl {
  if (Platform.isAndroid) {
    return 'ws://10.0.2.2:8080';
  }

  return 'ws://localhost:8080';
}
