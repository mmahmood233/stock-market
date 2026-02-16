import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/stock.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import 'custom_button.dart';

enum TradeType { buy, sell }

class TradeDialog extends StatefulWidget {
  final Stock stock;
  final TradeType type;
  final int? currentHoldings;

  const TradeDialog({
    super.key,
    required this.stock,
    required this.type,
    this.currentHoldings,
  });

  @override
  State<TradeDialog> createState() => _TradeDialogState();
}

class _TradeDialogState extends State<TradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  int _quantity = 0;
  double _totalCost = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    setState(() {
      _quantity = int.tryParse(_quantityController.text) ?? 0;
      _totalCost = _quantity * widget.stock.currentPrice;
    });
  }

  void _handleTrade() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    if (widget.type == TradeType.buy) {
      context.read<PortfolioBloc>().add(
            PortfolioBuyStock(
              userId: authState.user.id,
              symbol: widget.stock.symbol,
              name: widget.stock.name,
              quantity: _quantity,
              price: widget.stock.currentPrice,
            ),
          );
    } else {
      context.read<PortfolioBloc>().add(
            PortfolioSellStock(
              userId: authState.user.id,
              symbol: widget.stock.symbol,
              quantity: _quantity,
              price: widget.stock.currentPrice,
            ),
          );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.type == TradeType.buy;
    final color = isBuy ? AppColors.profitGreen : AppColors.lossRed;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final balance = authState is AuthAuthenticated ? authState.user.balance : 0.0;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isBuy ? Icons.add_shopping_cart : Icons.sell,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(isBuy ? 'Buy Stock' : 'Sell Stock'),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stock.symbol,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.stock.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatCurrency(widget.stock.currentPrice),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isBuy && widget.currentHoldings != null) ...[
                    Text(
                      'Available: ${widget.currentHoldings} shares',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (isBuy) ...[
                    Text(
                      'Balance: ${Formatters.formatCurrency(balance)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter number of shares',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => _updateTotal(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Please enter a valid quantity';
                      }
                      if (isBuy) {
                        final cost = qty * widget.stock.currentPrice;
                        if (cost > balance) {
                          return 'Insufficient balance';
                        }
                      } else {
                        if (widget.currentHoldings != null && qty > widget.currentHoldings!) {
                          return 'Insufficient shares';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total ${isBuy ? 'Cost' : 'Revenue'}:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              Formatters.formatCurrency(_totalCost),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                            ),
                          ],
                        ),
                        if (isBuy && _totalCost > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Remaining Balance:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                Formatters.formatCurrency(balance - _totalCost),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: isBuy ? 'Buy' : 'Sell',
              onPressed: _handleTrade,
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
          ],
        );
      },
    );
  }
}
