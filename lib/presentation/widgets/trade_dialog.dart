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

/// The two supported trade actions.
enum TradeType { buy, sell }

/// Buy/Sell modal opened from [StockDetailPage].
///
/// It validates quantity, shows a confirmation dialog, then sends
/// [PortfolioBuyStock] or [PortfolioSellStock] to [PortfolioBloc].
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
      // Keep the total cost or revenue live as the user types.
      final parsed = int.tryParse(_quantityController.text) ?? 0;
      _quantity = parsed < 0 ? 0 : parsed;
      _totalCost = _quantity * widget.stock.currentPrice;
    });
  }

  Future<void> _handleTrade() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final isBuy = widget.type == TradeType.buy;
    final color = isBuy ? AppColors.profitGreen : AppColors.lossRed;

    // This confirmation prevents accidental buy or sell operations.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${isBuy ? 'Buy' : 'Sell'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfirmRow(label: 'Stock', value: widget.stock.symbol),
            _ConfirmRow(label: 'Quantity', value: '$_quantity shares'),
            _ConfirmRow(
              label: 'Price',
              value: Formatters.formatCurrency(widget.stock.currentPrice),
            ),
            const Divider(height: 24),
            _ConfirmRow(
              label: isBuy ? 'Total cost' : 'Total revenue',
              value: Formatters.formatCurrency(_totalCost),
              valueColor: color,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(isBuy ? 'Confirm Buy' : 'Confirm Sell'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

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
        final balance = authState is AuthAuthenticated
            ? authState.user.balance
            : 0.0;
        // Max quantity depends on fake cash for buys and holdings for sells.
        final maxBuyQuantity = widget.stock.currentPrice > 0
            ? balance ~/ widget.stock.currentPrice
            : 0;
        final maxSellQuantity = widget.currentHoldings ?? 0;
        final maxQuantity = isBuy ? maxBuyQuantity : maxSellQuantity;

        return AlertDialog(
          title: Row(
            children: [
              Icon(isBuy ? Icons.add_shopping_cart : Icons.sell, color: color),
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
                      color: AppColors.borderDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stock.symbol,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.stock.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatCurrency(widget.stock.currentPrice),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isBuy && widget.currentHoldings != null) ...[
                    Text(
                      'Available: ${widget.currentHoldings} shares',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (isBuy) ...[
                    Text(
                      'Balance: ${Formatters.formatCurrency(balance)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                    controller: _quantityController,
                    decoration:
                        const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Enter number of shares',
                          prefixIcon: Icon(Icons.numbers),
                        ).copyWith(
                          suffixIcon: TextButton(
                            onPressed: maxQuantity > 0
                                ? () {
                                    _quantityController.text = maxQuantity
                                        .toString();
                                    _updateTotal();
                                  }
                                : null,
                            child: const Text('Max'),
                          ),
                        ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
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
                      if (widget.stock.currentPrice <= 0) {
                        return 'Stock price is not available';
                      }
                      if (isBuy) {
                        final cost = qty * widget.stock.currentPrice;
                        if (cost > balance) {
                          return 'Insufficient balance';
                        }
                        if (qty > maxBuyQuantity) {
                          return 'Maximum buy quantity is $maxBuyQuantity';
                        }
                      } else {
                        if (widget.currentHoldings == null ||
                            widget.currentHoldings == 0) {
                          return 'You do not own this stock';
                        }
                        if (qty > widget.currentHoldings!) {
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
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                Formatters.formatCurrency(_totalCost),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
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
                                'Remaining:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  Formatters.formatCurrency(
                                    balance - _totalCost,
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: (balance - _totalCost) < 0
                                            ? AppColors.lossRed
                                            : AppColors.profitGreen,
                                      ),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
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

/// Small label/value row used inside the trade confirmation dialog.
class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ConfirmRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
