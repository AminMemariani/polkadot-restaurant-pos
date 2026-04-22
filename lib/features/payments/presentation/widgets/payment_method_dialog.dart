import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:step_bar/step_bar.dart';

import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/motion/motion.dart';
import '../../domain/entities/money.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/services/payment_method_registry.dart';
import '../../domain/services/payment_processor.dart';
import '../pages/payment_confirmation_page.dart';
import '../providers/payments_provider.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

/// Cashier-facing payment method picker.
///
/// Enumerates rails from [PaymentMethodRegistry] so adding a new processor
/// (Stripe, Apple Pay, gift card) shows up here automatically. Routing per
/// rail still lives in [_processPayment] — that's the next refactor target
/// once Stripe lands and we have more than two flow shapes to manage.
class PaymentMethodDialog extends StatefulWidget {
  final double amount;
  final String? receiptId;

  const PaymentMethodDialog({super.key, required this.amount, this.receiptId});

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  PaymentProcessor? _selected;
  bool _isLoading = false;
  List<PaymentProcessor> _processors = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProcessors());
  }

  Future<void> _loadProcessors() async {
    final registry = context.read<PaymentMethodRegistry>();
    final available = await registry.available();
    if (!mounted) return;
    setState(() => _processors = available);
  }

  Widget _buildPaymentSteps(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final steps = [
      const StepBarStep(
        label: 'Select Payment Method',
        status: StepStatus.active,
      ),
      const StepBarStep(label: 'Process Payment', status: StepStatus.inactive),
      const StepBarStep(label: 'Confirmation', status: StepStatus.inactive),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
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
            currentStep: 0,
            completedColor: colorScheme.primary,
            activeColor: colorScheme.primary.withValues(alpha: 0.3),
            inactiveColor: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassDialog(
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
            _buildPaymentSteps(context),

            const SizedBox(height: 16),

            // Amount Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
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

            if (_processors.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              )
            else
              Column(
                children: _processors
                    .map((p) => _MethodTile(
                          processor: p,
                          isSelected: _selected?.method == p.method,
                          onTap: () => setState(() => _selected = p),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface)),
        ),
        FilledButton(
          onPressed: _isLoading || _selected == null ? null : _processPayment,
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

  Future<void> _processPayment() async {
    final processor = _selected;
    if (processor == null) return;

    setState(() => _isLoading = true);

    final provider = context.read<PaymentsProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;

    final request = PaymentRequest(
      orderId:
          widget.receiptId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: Money.fromMajor(widget.amount, 'USD'),
      // TODO(multi-tenant): wire real cashier/location once auth lands.
      cashierId: 'default',
      locationId: 'default',
    );

    try {
      if (processor.method == PaymentMethod.cash) {
        // Cash resolves immediately; record it through the legacy repo and
        // snackbar back without leaving the order screen.
        await processor.process(request).drain<void>();
        await provider.recordPayment(
          Payment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: 'completed',
            amount: widget.amount,
            receiptId: widget.receiptId ?? '',
            method: 'cash',
            createdAt: DateTime.now(),
          ),
        );
        if (mounted) {
          navigator.pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Payment completed with ${processor.displayName}'),
              backgroundColor: primaryColor,
            ),
          );
        }
        return;
      }

      // Interactive rails (blockchain, Stripe later): start the processor
      // stream and let PaymentConfirmationPage observe it.
      await provider.startProcessor(processor, request);
      if (mounted) {
        navigator.pop();
        navigator.push(
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationPage(
              amount: widget.amount,
              network: processor.displayName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Single tile in the payment-method picker. Animates the border and
/// background when selection changes.
class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.processor,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentProcessor processor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isBlockchain = processor.method == PaymentMethod.polkadot ||
        processor.method == PaymentMethod.kusama;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isBlockchain
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(processor.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      processor.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isBlockchain) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Blockchain Payment',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? AppIcons.checkCircle
                    : AppIcons.radioButtonUnchecked,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

