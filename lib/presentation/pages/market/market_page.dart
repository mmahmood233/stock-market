import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/stock.dart';
import '../../bloc/stock/stock_bloc.dart';
import '../../bloc/stock/stock_event.dart';
import '../../bloc/stock/stock_state.dart';
import '../../widgets/stock_card.dart';
import '../stock_detail/stock_detail_page.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<StockBloc>().add(const StockRealtimeStarted());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Stock> _filterStocks(List<Stock> stocks) {
    if (_searchQuery.isEmpty) return stocks;
    
    return stocks.where((stock) {
      final query = _searchQuery.toLowerCase();
      return stock.symbol.toLowerCase().contains(query) ||
             stock.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search stocks...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<StockBloc, StockState>(
            builder: (context, state) {
              if (state is StockLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is StockError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading stocks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<StockBloc>().add(const StockRefreshRequested());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                      if (state.cachedStocks != null && state.cachedStocks!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            context.read<StockBloc>().add(const StockLoadRequested());
                          },
                          child: const Text('View Cached Data'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              if (state is StockEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No stocks available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<StockBloc>().add(const StockRefreshRequested());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              if (state is StockLoaded) {
                final filteredStocks = _filterStocks(state.stocks);

                if (filteredStocks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stocks found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<StockBloc>().add(const StockRefreshRequested());
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStocks.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                state.isRealtime
                                    ? Icons.wifi
                                    : Icons.wifi_off,
                                size: 16,
                                color: state.isRealtime
                                    ? AppColors.success
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.isRealtime
                                    ? 'Live Updates'
                                    : 'Offline Mode',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: state.isRealtime
                                          ? AppColors.success
                                          : Colors.grey,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                '${filteredStocks.length} stocks',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      final stock = filteredStocks[index - 1];
                      return StockCard(
                        stock: stock,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StockDetailPage(stock: stock),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return const Center(
                child: Text('Unknown state'),
              );
            },
          ),
        ),
      ],
    );
  }
}
