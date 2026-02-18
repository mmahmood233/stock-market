import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/stock.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/portfolio/portfolio_bloc.dart';
import '../../bloc/portfolio/portfolio_event.dart';
import '../../bloc/portfolio/portfolio_state.dart';
import '../../bloc/stock/stock_bloc.dart';
import '../../bloc/stock/stock_state.dart';
import '../../bloc/stock_history/stock_history_bloc.dart';
import '../../bloc/stock_history/stock_history_event.dart';
import '../../bloc/stock_history/stock_history_state.dart';
import '../../widgets/stock_chart.dart';
import '../../widgets/trade_dialog.dart';

class StockDetailPage extends StatefulWidget {
  final Stock stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
    _loadPortfolio();
  }

  void _loadHistoricalData() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    
    context.read<StockHistoryBloc>().add(
          StockHistoryRequested(
            symbol: widget.stock.symbol,
            startDate: startDate,
            endDate: endDate,
          ),
        );
  }

  void _loadPortfolio() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PortfolioBloc>().add(
            PortfolioLoadRequested(authState.user.id),
          );
    }
  }

  void _showTradeDialog(TradeType type) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    int? currentHoldings;
    final portfolioState = context.read<PortfolioBloc>().state;
    if (portfolioState is PortfolioLoaded) {
      final holding = portfolioState.stocks.cast<dynamic>().firstWhere(
        (s) => s.symbol == widget.stock.symbol,
        orElse: () => null,
      );
      currentHoldings = holding?.quantity;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AuthBloc>()),
          BlocProvider.value(value: context.read<PortfolioBloc>()),
        ],
        child: TradeDialog(
          stock: widget.stock,
          type: type,
          currentHoldings: currentHoldings,
        ),
      ),
    ).then((_) => _loadPortfolio());
  }

  Stock _getCurrentStock(StockState stockState) {
    if (stockState is StockLoaded) {
      final updatedStock = stockState.stocks.firstWhere(
        (s) => s.symbol == widget.stock.symbol,
        orElse: () => widget.stock,
      );
      return updatedStock;
    }
    return widget.stock;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stock.symbol),
      ),
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, stockState) {
          final currentStock = _getCurrentStock(stockState);
          final isPositive = currentStock.isPositive;
          final changeColor = isPositive ? AppColors.profitGreen : AppColors.lossRed;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStock.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentStock.symbol,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        Formatters.formatCurrency(currentStock.currentPrice),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: changeColor,
                            size: 24,
                          ),
                          Text(
                            '${Formatters.formatCurrency(currentStock.changeAmount.abs())} (${Formatters.formatPercentage(currentStock.changePercentage.abs())})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: changeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildDataRow(
                        context,
                        'Previous Close',
                        Formatters.formatCurrency(currentStock.previousClose),
                      ),
                      const Divider(height: 24),
                      _buildDataRow(
                        context,
                        'Day High',
                        Formatters.formatCurrency(currentStock.dayHigh),
                      ),
                      const Divider(height: 24),
                      _buildDataRow(
                        context,
                        'Day Low',
                        Formatters.formatCurrency(currentStock.dayLow),
                      ),
                      const Divider(height: 24),
                      _buildDataRow(
                        context,
                        'Volume',
                        Formatters.formatCompactNumber(currentStock.volume),
                      ),
                      const Divider(height: 24),
                      _buildDataRow(
                        context,
                        'Last Updated',
                        Formatters.formatDateTime(currentStock.lastUpdated),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historical Chart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<StockHistoryBloc, StockHistoryState>(
                    builder: (context, state) {
                      if (state is StockHistoryLoaded && 
                          state.symbol == widget.stock.symbol) {
                        return StockChart(
                          history: state.history,
                          isLoading: false,
                        );
                      } else if (state is StockHistoryLoading) {
                        return const StockChart(
                          history: [],
                          isLoading: true,
                        );
                      } else if (state is StockHistoryError) {
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load chart',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _loadHistoricalData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const StockChart(
                        history: [],
                        isLoading: true,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
              const SizedBox(height: 16),
              BlocBuilder<PortfolioBloc, PortfolioState>(
                builder: (context, portfolioState) {
                  int? currentHoldings;
                  if (portfolioState is PortfolioLoaded) {
                    final holding = portfolioState.stocks.cast<dynamic>().firstWhere(
                      (s) => s.symbol == currentStock.symbol,
                      orElse: () => null,
                    );
                    currentHoldings = holding?.quantity;
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trade',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (currentHoldings != null && currentHoldings > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.profitGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: AppColors.profitGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'You own $currentHoldings shares',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.profitGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showTradeDialog(TradeType.buy),
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text('Buy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.profitGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: currentHoldings != null && currentHoldings > 0
                                      ? () => _showTradeDialog(TradeType.sell)
                                      : null,
                                  icon: const Icon(Icons.sell),
                                  label: const Text('Sell'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lossRed,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
