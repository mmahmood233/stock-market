import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/stock_history.dart';

enum ChartPeriod { day, week, month, year, all }

class StockChart extends StatefulWidget {
  final List<StockHistory> history;
  final bool isLoading;

  const StockChart({
    super.key,
    required this.history,
    this.isLoading = false,
  });

  @override
  State<StockChart> createState() => _StockChartState();
}

class _StockChartState extends State<StockChart> {
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  List<StockHistory> _getFilteredHistory() {
    if (widget.history.isEmpty) return [];

    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case ChartPeriod.day:
        startDate = now.subtract(const Duration(days: 1));
        break;
      case ChartPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case ChartPeriod.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
      case ChartPeriod.all:
        return widget.history;
    }

    return widget.history
        .where((h) => h.timestamp.isAfter(startDate))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.history.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.show_chart,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No historical data available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredHistory = _getFilteredHistory();
    if (filteredHistory.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No data for selected period'),
        ),
      );
    }

    return Column(
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 16),
            child: LineChart(
              _buildChartData(filteredHistory),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getPeriodLabel(period)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodLabel(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.day:
        return '1D';
      case ChartPeriod.week:
        return '1W';
      case ChartPeriod.month:
        return '1M';
      case ChartPeriod.year:
        return '1Y';
      case ChartPeriod.all:
        return 'ALL';
    }
  }

  LineChartData _buildChartData(List<StockHistory> history) {
    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();

    final minY = history.map((h) => h.low).reduce((a, b) => a < b ? a : b);
    final maxY = history.map((h) => h.high).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    final firstPrice = history.first.close;
    final lastPrice = history.last.close;
    final isPositive = lastPrice >= firstPrice;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                Formatters.formatCurrency(value),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (history.length / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= history.length) return const SizedBox();
              final date = history[value.toInt()].timestamp;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: minY - padding,
      maxY: maxY + padding,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: isPositive ? AppColors.profitGreen : AppColors.lossRed,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: (isPositive ? AppColors.profitGreen : AppColors.lossRed)
                .withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = history[spot.x.toInt()].timestamp;
              return LineTooltipItem(
                '${Formatters.formatCurrency(spot.y)}\n${Formatters.formatDate(date)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      case ChartPeriod.week:
      case ChartPeriod.month:
        return '${date.month}/${date.day}';
      case ChartPeriod.year:
      case ChartPeriod.all:
        return '${date.month}/${date.year.toString().substring(2)}';
    }
  }
}
