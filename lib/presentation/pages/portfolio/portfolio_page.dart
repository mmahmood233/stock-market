import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/portfolio/portfolio_bloc.dart';
import '../../bloc/portfolio/portfolio_event.dart';
import '../../bloc/portfolio/portfolio_state.dart';
import '../home/home_page.dart';
import '../../bloc/stock/stock_bloc.dart';
import '../../bloc/stock/stock_state.dart';
import '../../../domain/entities/portfolio_stock.dart';
import '../../../domain/entities/stock.dart';
import '../../widgets/portfolio_stock_card.dart';
import '../stock_detail/stock_detail_page.dart';
import 'transaction_history_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  void _loadPortfolio() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PortfolioBloc>().add(
        PortfolioLoadRequested(authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioBloc, PortfolioState>(
      listener: (context, state) {
        if (state is PortfolioTransactionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is PortfolioError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PortfolioInitial || state is PortfolioTransactionSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadPortfolio();
            }
          });
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PortfolioError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading wallet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadPortfolio,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is PortfolioEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 80,
                  color: AppColors.mutedText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Holdings Yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start trading to build your wallet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    final homePageState = context
                        .findAncestorStateOfType<HomePageState>();
                    if (homePageState != null) {
                      homePageState.navigateToMarket();
                    }
                  },
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Browse Stocks'),
                ),
              ],
            ),
          );
        }

        if (state is PortfolioLoaded) {
          return BlocBuilder<StockBloc, StockState>(
            builder: (context, stockState) {
              // Override currentPrice with live prices if available
              List<PortfolioStock> liveStocks = state.stocks;
              if (stockState is StockLoaded) {
                liveStocks = state.stocks.map((ps) {
                  final liveIndex = stockState.stocks.indexWhere(
                    (s) => s.symbol == ps.symbol,
                  );
                  if (liveIndex == -1) return ps;

                  final live = stockState.stocks[liveIndex];
                  return ps.copyWith(currentPrice: live.currentPrice);
                }).toList();
              }

              final totalValue = liveStocks.fold<double>(
                0,
                (sum, s) => sum + s.currentValue,
              );
              final totalInvestment = liveStocks.fold<double>(
                0,
                (sum, s) => sum + s.totalInvestment,
              );
              final totalProfitLoss = totalValue - totalInvestment;
              final totalProfitLossPercentage = totalInvestment > 0
                  ? (totalProfitLoss / totalInvestment) * 100
                  : 0.0;
              final isProfit = totalProfitLoss >= 0;
              final profitColor = isProfit
                  ? AppColors.profitGreen
                  : AppColors.lossRed;

              return RefreshIndicator(
                onRefresh: () async {
                  _loadPortfolio();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Value',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.history),
                                  onPressed: () {
                                    final authState = context
                                        .read<AuthBloc>()
                                        .state;
                                    if (authState is AuthAuthenticated) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context
                                                .read<PortfolioBloc>(),
                                            child: TransactionHistoryPage(
                                              userId: authState.user.id,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Transaction History',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.formatCurrency(totalValue),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Investment',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.mutedText,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.formatCurrency(
                                          totalInvestment,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Profit/Loss',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.mutedText,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            isProfit
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: profitColor,
                                            size: 20,
                                          ),
                                          Text(
                                            Formatters.formatCurrency(
                                              totalProfitLoss.abs(),
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: profitColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: profitColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${isProfit ? '+' : ''}${Formatters.formatPercentage(totalProfitLossPercentage.abs())}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: profitColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Holdings (${liveStocks.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...liveStocks.map(
                      (stock) => PortfolioStockCard(
                        stock: stock,
                        onTap: () {
                          final detailStock = _stockForDetail(
                            stock,
                            stockState is StockLoaded ? stockState : null,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  StockDetailPage(stock: detailStock),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return Center(
          child: ElevatedButton.icon(
            onPressed: _loadPortfolio,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload Wallet'),
          ),
        );
      },
    );
  }

  Stock _stockForDetail(PortfolioStock stock, StockLoaded? stockState) {
    if (stockState != null) {
      final liveIndex = stockState.stocks.indexWhere(
        (liveStock) => liveStock.symbol == stock.symbol,
      );
      if (liveIndex != -1) {
        return stockState.stocks[liveIndex];
      }
    }

    return Stock(
      symbol: stock.symbol,
      name: stock.name,
      currentPrice: stock.currentPrice,
      previousClose: stock.averageBuyPrice,
      changeAmount: stock.currentPrice - stock.averageBuyPrice,
      changePercentage: stock.averageBuyPrice > 0
          ? ((stock.currentPrice - stock.averageBuyPrice) /
                    stock.averageBuyPrice) *
                100
          : 0,
      dayHigh: stock.currentPrice,
      dayLow: stock.currentPrice,
      volume: 0,
      lastUpdated: stock.lastUpdated,
    );
  }
}
