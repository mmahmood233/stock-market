import 'package:equatable/equatable.dart';
import '../../../domain/entities/portfolio_stock.dart';
import '../../../domain/entities/transaction.dart';

/// Base class for Wallet states rendered by [PortfolioPage].
abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

/// No Wallet action has started yet.
class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

/// Wallet should show a loading spinner.
class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

/// Wallet holdings and calculated totals are ready.
class PortfolioLoaded extends PortfolioState {
  final List<PortfolioStock> stocks;
  final double totalValue;
  final double totalInvestment;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;

  const PortfolioLoaded({
    required this.stocks,
    required this.totalValue,
    required this.totalInvestment,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
  });

  /// Builds totals from the holdings list so the UI does not recalculate them.
  factory PortfolioLoaded.fromStocks(List<PortfolioStock> stocks) {
    final totalValue = stocks.fold<double>(
      0,
      (sum, stock) => sum + stock.currentValue,
    );
    final totalInvestment = stocks.fold<double>(
      0,
      (sum, stock) => sum + stock.totalInvestment,
    );
    final totalProfitLoss = totalValue - totalInvestment;
    final totalProfitLossPercentage = totalInvestment > 0
        ? (totalProfitLoss / totalInvestment) * 100
        : 0.0;

    return PortfolioLoaded(
      stocks: stocks,
      totalValue: totalValue,
      totalInvestment: totalInvestment,
      totalProfitLoss: totalProfitLoss,
      totalProfitLossPercentage: totalProfitLossPercentage,
    );
  }

  @override
  List<Object?> get props => [
    stocks,
    totalValue,
    totalInvestment,
    totalProfitLoss,
    totalProfitLossPercentage,
  ];
}

/// A buy or sell completed successfully.
///
/// [PortfolioPage] listens to this state to show a success SnackBar.
class PortfolioTransactionSuccess extends PortfolioState {
  final Transaction transaction;
  final String message;

  const PortfolioTransactionSuccess({
    required this.transaction,
    required this.message,
  });

  @override
  List<Object?> get props => [transaction, message];
}

/// Transaction History page should show [transactions].
class PortfolioTransactionHistoryLoaded extends PortfolioState {
  final List<Transaction> transactions;

  const PortfolioTransactionHistoryLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Wallet or trade action failed and should show [message].
class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
}

/// User has no holdings.
class PortfolioEmpty extends PortfolioState {
  const PortfolioEmpty();
}
