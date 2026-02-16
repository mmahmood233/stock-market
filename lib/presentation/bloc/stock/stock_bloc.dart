import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/stock_repository.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository stockRepository;
  StreamSubscription? _stockSubscription;

  StockBloc({required this.stockRepository}) : super(const StockInitial()) {
    on<StockLoadRequested>(_onLoadRequested);
    on<StockRealtimeStarted>(_onRealtimeStarted);
    on<StockRealtimeStopped>(_onRealtimeStopped);
    on<StockHistoryRequested>(_onHistoryRequested);
    on<StockRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    StockLoadRequested event,
    Emitter<StockState> emit,
  ) async {
    emit(const StockLoading());

    final result = await stockRepository.getCachedStocks();

    result.fold(
      (failure) => emit(StockError(failure.message)),
      (stocks) {
        if (stocks.isEmpty) {
          emit(const StockEmpty());
        } else {
          emit(StockLoaded(stocks: stocks));
        }
      },
    );
  }

  Future<void> _onRealtimeStarted(
    StockRealtimeStarted event,
    Emitter<StockState> emit,
  ) async {
    await _stockSubscription?.cancel();

    emit(const StockLoading());

    _stockSubscription = stockRepository.getRealtimeStocks().listen(
      (result) {
        result.fold(
          (failure) {
            if (!isClosed) {
              add(const StockLoadRequested());
            }
          },
          (stocks) {
            if (!isClosed) {
              if (stocks.isEmpty) {
                emit(const StockEmpty());
              } else {
                emit(StockLoaded(stocks: stocks, isRealtime: true));
              }
            }
          },
        );
      },
      onError: (error) {
        if (!isClosed) {
          emit(StockError(
            'Real-time connection failed: $error',
          ));
        }
      },
    );
  }

  Future<void> _onRealtimeStopped(
    StockRealtimeStopped event,
    Emitter<StockState> emit,
  ) async {
    await _stockSubscription?.cancel();
    _stockSubscription = null;

    if (state is StockLoaded) {
      final currentState = state as StockLoaded;
      emit(currentState.copyWith(isRealtime: false));
    }
  }

  Future<void> _onHistoryRequested(
    StockHistoryRequested event,
    Emitter<StockState> emit,
  ) async {
    final result = await stockRepository.getStockHistory(
      symbol: event.symbol,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StockError(failure.message)),
      (history) => emit(StockHistoryLoaded(
        symbol: event.symbol,
        history: history,
      )),
    );
  }

  Future<void> _onRefreshRequested(
    StockRefreshRequested event,
    Emitter<StockState> emit,
  ) async {
    add(const StockRealtimeStarted());
  }

  @override
  Future<void> close() {
    _stockSubscription?.cancel();
    return super.close();
  }
}
