// Picks the correct stock server config file for the current platform.
//
// Native apps use `stock_server_config_io.dart`; web uses
// `stock_server_config_web.dart` because `dart:io` is not available there.
export 'stock_server_config_io.dart'
    if (dart.library.html) 'stock_server_config_web.dart';
