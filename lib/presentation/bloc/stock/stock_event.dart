import 'package:equatable/equatable.dart';

/// Base class for Market stock actions sent to [StockBloc].
abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

/// Loads cached stocks when the app is offline or user asks for cached data.
class StockLoadRequested extends StockEvent {
  const StockLoadRequested();
}

/// Starts the live WebSocket stream used by [MarketPage].
class StockRealtimeStarted extends StockEvent {
  const StockRealtimeStarted();
}

/// Stops the live stream when needed.
class StockRealtimeStopped extends StockEvent {
  const StockRealtimeStopped();
}

/// Restarts the live stream when the user taps Retry or pulls to refresh.
class StockRefreshRequested extends StockEvent {
  const StockRefreshRequested();
}
