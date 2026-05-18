import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/portfolio_repository.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

/// Handles Wallet holdings, buy/sell actions, and transaction history.
///
/// [PortfolioPage], [TradeDialog], and [TransactionHistoryPage] dispatch events
/// here. This BLoC also tells [AuthBloc] when the cash balance changes.
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository portfolioRepository;
  final AuthBloc authBloc;

  PortfolioBloc({required this.portfolioRepository, required this.authBloc})
    : super(const PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onLoadRequested);
    on<PortfolioBuyStock>(_onBuyStock);
    on<PortfolioSellStock>(_onSellStock);
    on<PortfolioUpdatePrices>(_onUpdatePrices);
    on<PortfolioTransactionHistoryRequested>(_onTransactionHistoryRequested);
    on<PortfolioRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    PortfolioLoadRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());

    // Wallet uses the logged-in user id to keep accounts separate.
    final result = await portfolioRepository.getPortfolio(event.userId);

    result.fold((failure) => emit(PortfolioError(failure.message)), (stocks) {
      if (stocks.isEmpty) {
        emit(const PortfolioEmpty());
      } else {
        emit(PortfolioLoaded.fromStocks(stocks));
      }
    });
  }

  Future<void> _onBuyStock(
    PortfolioBuyStock event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());

    final totalCost = event.quantity * event.price;
    final currentState = authBloc.state;

    // The BLoC repeats key validation so tests or other screens cannot bypass it.
    if (currentState is! AuthAuthenticated ||
        currentState.user.id != event.userId) {
      emit(const PortfolioError('You must be logged in to buy stocks'));
      return;
    }

    if (totalCost > currentState.user.balance) {
      emit(const PortfolioError('Insufficient balance'));
      return;
    }

    final result = await portfolioRepository.buyStock(
      userId: event.userId,
      symbol: event.symbol,
      name: event.name,
      quantity: event.quantity,
      price: event.price,
    );

    await result.fold((failure) async => emit(PortfolioError(failure.message)), (
      transaction,
    ) async {
      // Update fake cash after the holding was saved successfully.
      authBloc.add(AuthUpdateBalance(currentState.user.balance - totalCost));

      emit(
        PortfolioTransactionSuccess(
          transaction: transaction,
          message:
              'Successfully bought ${event.quantity} shares of ${event.symbol}',
        ),
      );

      add(PortfolioLoadRequested(event.userId));
    });
  }

  Future<void> _onSellStock(
    PortfolioSellStock event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());

    final totalRevenue = event.quantity * event.price;

    // The repository checks the saved holding quantity before selling.
    final result = await portfolioRepository.sellStock(
      userId: event.userId,
      symbol: event.symbol,
      quantity: event.quantity,
      price: event.price,
    );

    await result.fold(
      (failure) async => emit(PortfolioError(failure.message)),
      (transaction) async {
        final currentState = authBloc.state;
        if (currentState is AuthAuthenticated) {
          // Add fake cash back after a successful sale.
          authBloc.add(
            AuthUpdateBalance(currentState.user.balance + totalRevenue),
          );
        }

        emit(
          PortfolioTransactionSuccess(
            transaction: transaction,
            message:
                'Successfully sold ${event.quantity} shares of ${event.symbol}',
          ),
        );

        add(PortfolioLoadRequested(event.userId));
      },
    );
  }

  Future<void> _onUpdatePrices(
    PortfolioUpdatePrices event,
    Emitter<PortfolioState> emit,
  ) async {
    // Called when live prices change and Wallet holdings need fresh values.
    for (final entry in event.prices.entries) {
      await portfolioRepository.updatePortfolioStockPrice(
        userId: event.userId,
        symbol: entry.key,
        newPrice: entry.value,
      );
    }

    add(PortfolioLoadRequested(event.userId));
  }

  Future<void> _onTransactionHistoryRequested(
    PortfolioTransactionHistoryRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());

    // Transaction History page uses this to show the audit trail.
    final result = await portfolioRepository.getTransactionHistory(
      event.userId,
    );

    result.fold(
      (failure) => emit(PortfolioError(failure.message)),
      (transactions) => emit(PortfolioTransactionHistoryLoaded(transactions)),
    );
  }

  Future<void> _onRefreshRequested(
    PortfolioRefreshRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    add(PortfolioLoadRequested(event.userId));
  }
}
