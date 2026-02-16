import 'package:equatable/equatable.dart';
import '../../../domain/entities/portfolio_stock.dart';
import '../../../domain/entities/transaction.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {
  const PortfolioInitial();
}

class PortfolioLoading extends PortfolioState {
  const PortfolioLoading();
}

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

class PortfolioTransactionHistoryLoaded extends PortfolioState {
  final List<Transaction> transactions;

  const PortfolioTransactionHistoryLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object?> get props => [message];
}

class PortfolioEmpty extends PortfolioState {
  const PortfolioEmpty();
}
