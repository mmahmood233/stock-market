import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/stock.dart';
import '../../bloc/stock/stock_bloc.dart';
import '../../bloc/stock/stock_event.dart';
import '../../bloc/stock/stock_state.dart';
import '../../widgets/stock_chart.dart';

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
  }

  void _loadHistoricalData() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    
    context.read<StockBloc>().add(
          StockHistoryRequested(
            symbol: widget.stock.symbol,
            startDate: startDate,
            endDate: endDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.stock.isPositive;
    final changeColor = isPositive ? AppColors.profitGreen : AppColors.lossRed;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stock.symbol),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stock.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.stock.symbol,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Formatters.formatCurrency(widget.stock.currentPrice),
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
                        '${Formatters.formatCurrency(widget.stock.changeAmount.abs())} (${Formatters.formatPercentage(widget.stock.changePercentage.abs())})',
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
                    Formatters.formatCurrency(widget.stock.previousClose),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Day High',
                    Formatters.formatCurrency(widget.stock.dayHigh),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Day Low',
                    Formatters.formatCurrency(widget.stock.dayLow),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Volume',
                    Formatters.formatCompactNumber(widget.stock.volume),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Last Updated',
                    Formatters.formatDateTime(widget.stock.lastUpdated),
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
                  BlocBuilder<StockBloc, StockState>(
                    builder: (context, state) {
                      if (state is StockHistoryLoaded && 
                          state.symbol == widget.stock.symbol) {
                        return StockChart(
                          history: state.history,
                          isLoading: false,
                        );
                      } else if (state is StockLoading) {
                        return const StockChart(
                          history: [],
                          isLoading: true,
                        );
                      } else if (state is StockError) {
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Buy/Sell',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coming in Phase 8',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
