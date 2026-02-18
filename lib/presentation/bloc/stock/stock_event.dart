import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class StockLoadRequested extends StockEvent {
  const StockLoadRequested();
}

class StockRealtimeStarted extends StockEvent {
  const StockRealtimeStarted();
}

class StockRealtimeStopped extends StockEvent {
  const StockRealtimeStopped();
}

class StockRefreshRequested extends StockEvent {
  const StockRefreshRequested();
}
