import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/stock_repository.dart';
import 'stock_history_event.dart';
import 'stock_history_state.dart';

class StockHistoryBloc extends Bloc<StockHistoryEvent, StockHistoryState> {
  final StockRepository stockRepository;

  StockHistoryBloc({required this.stockRepository}) : super(const StockHistoryInitial()) {
    on<StockHistoryRequested>(_onHistoryRequested);
  }

  Future<void> _onHistoryRequested(
    StockHistoryRequested event,
    Emitter<StockHistoryState> emit,
  ) async {
    emit(const StockHistoryLoading());

    final result = await stockRepository.getStockHistory(
      symbol: event.symbol,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StockHistoryError(failure.message)),
      (history) => emit(StockHistoryLoaded(
        symbol: event.symbol,
        history: history,
      )),
    );
  }
}
