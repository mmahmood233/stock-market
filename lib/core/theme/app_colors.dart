import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// Theme and widgets use these values to keep the Binance-style dark trading
/// look consistent across Market, Wallet, and Stock Detail screens.
class AppColors {
  static const Color primary = Color(0xFFF0B90B);
  static const Color secondary = Color(0xFFFCD535);

  static const Color success = Color(0xFF0ECB81);
  static const Color error = Color(0xFFF6465D);
  static const Color warning = Color(0xFFF0B90B);

  static const Color profitGreen = Color(0xFF0ECB81);
  static const Color lossRed = Color(0xFFF6465D);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0B0E11);

  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF181A20);
  static const Color borderDark = Color(0xFF2B3139);
  static const Color mutedText = Color(0xFF848E9C);
}
