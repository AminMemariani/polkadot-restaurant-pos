import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_bar/step_bar.dart';

import '../providers/payments_provider.dart';
import '../pages/payment_confirmation_page.dart';
import '../../domain/entities/payment.dart';

class PaymentMethodDialog extends StatefulWidget {
  final double amount;

  const PaymentMethodDialog({super.key, required this.amount});

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  String? _selectedMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final provider = context.read<PaymentsProvider>();
    await provider.getAvailablePaymentMethods();
  }

  Widget _buildPaymentSteps(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define payment steps for method selection
    final steps = ['Select Payment Method', 'Process Payment', 'Confirmation'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Process',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          StepBar(
            steps: steps,
            currentStep: 0, // Currently on step 1 (Select Payment Method)
            completedColor: colorScheme.primary,
            activeColor: colorScheme.primary.withOpacity(0.3),
            inactiveColor: colorScheme.onSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        'Select Payment Method',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Payment Steps
            _buildPaymentSteps(context),

            const SizedBox(height: 16),

            // Amount Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods
            Consumer<PaymentsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: provider.paymentMethods.map((method) {
                    final isSelected = _selectedMethod == method;
                    final isBlockchain =
                        method.toLowerCase().contains('polkadot') ||
                        method.toLowerCase().contains('kusama');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMethod = method;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer.withOpacity(0.3)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Payment Method Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isBlockchain
                                      ? colorScheme.primary
                                      : colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isBlockchain
                                      ? Icons.account_balance_wallet
                                      : method.toLowerCase().contains('card')
                                      ? Icons.credit_card
                                      : Icons.payments,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Method Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    if (isBlockchain) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Blockchain Payment',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Selection Indicator
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: colorScheme.primary,
                                  size: 24,
                                )
                              else
                                Icon(
                                  Icons.radio_button_unchecked,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface)),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedMethod == null
              ? null
              : () => _processPayment(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    if (_selectedMethod == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<PaymentsProvider>();

      // Check if it's a blockchain payment
      final isBlockchain =
          _selectedMethod!.toLowerCase().contains('polkadot') ||
          _selectedMethod!.toLowerCase().contains('kusama');

      if (isBlockchain) {
        // Process blockchain payment
        final success = await provider.processPaymentWithBlockchain(
          amount: widget.amount,
          network: _selectedMethod!,
        );

        if (success && mounted) {
          Navigator.of(context).pop();
          // Navigate to payment confirmation page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentConfirmationPage(
                amount: widget.amount,
                network: _selectedMethod,
              ),
            ),
          );
        }
      } else {
        // Process traditional payment
        final success = await provider.processPaymentTransaction(
          Payment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: 'completed',
            amount: widget.amount,
          ),
        );

        if (success && mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment completed with $_selectedMethod'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
