import 'package:intl/intl.dart';

/// Small formatting helpers used by UI widgets and pages.
///
/// Keeping formatting here means Market, Wallet, and Stock Detail screens show
/// money, percentages, dates, and volume in the same way.
class Formatters {
  /// Formats fake dollar balances, prices, costs, and revenue.
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Formats positive or negative percentages for stock changes and P/L.
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.decimalPattern();
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${formatter.format(percentage)}%';
  }

  /// Formats plain numbers with thousands separators.
  static String formatNumber(double number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }

  /// Formats a date for transaction history and profile metadata.
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats a date and time for live stock update labels.
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  /// Formats large numbers like volume using K, M, or B.
  static String formatCompactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }
}
