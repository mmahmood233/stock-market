import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/stock.dart';

class StockDetailPage extends StatelessWidget {
  final Stock stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.isPositive;
    final changeColor = isPositive ? AppColors.profitGreen : AppColors.lossRed;

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol),
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
                    stock.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stock.symbol,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Formatters.formatCurrency(stock.currentPrice),
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
                        '${Formatters.formatCurrency(stock.changeAmount.abs())} (${Formatters.formatPercentage(stock.changePercentage.abs())})',
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
                    Formatters.formatCurrency(stock.previousClose),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Day High',
                    Formatters.formatCurrency(stock.dayHigh),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Day Low',
                    Formatters.formatCurrency(stock.dayLow),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Volume',
                    Formatters.formatCompactNumber(stock.volume),
                  ),
                  const Divider(height: 24),
                  _buildDataRow(
                    context,
                    'Last Updated',
                    Formatters.formatDateTime(stock.lastUpdated),
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
                    Icons.show_chart,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Historical Chart',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coming in Phase 7',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
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
