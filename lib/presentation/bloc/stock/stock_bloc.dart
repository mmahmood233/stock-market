import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/stock.dart';
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

    await emit.forEach<Either<Failure, List<Stock>>>(
      stockRepository.getRealtimeStocks(),
      onData: (result) {
        return result.fold(
          (failure) {
            add(const StockLoadRequested());
            return StockError(failure.message);
          },
          (stocks) {
            if (stocks.isEmpty) {
              return const StockEmpty();
            } else {
              return StockLoaded(stocks: stocks, isRealtime: true);
            }
          },
        );
      },
      onError: (error, stackTrace) {
        return StockError('Real-time connection failed: $error');
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
