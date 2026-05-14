import 'dart:io' show Platform;

String get defaultStockServerUrl {
  if (Platform.isAndroid) {
    return 'ws://10.0.2.2:8080';
  }

  return 'ws://localhost:8080';
}
