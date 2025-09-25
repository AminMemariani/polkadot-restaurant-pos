import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:step_bar/step_bar.dart';

import '../providers/payments_provider.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final double amount;
  final String? network;

  const PaymentConfirmationPage({
    super.key,
    required this.amount,
    this.network,
  });

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    // Start payment process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPayment();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    final provider = context.read<PaymentsProvider>();
    await provider.startPayment(widget.amount);

    // Start pulse animation for waiting state
    if (provider.paymentStatus == PaymentStatus.waiting) {
      _pulseController.repeat(reverse: true);
    }

    // Simulate blockchain confirmation after delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && provider.paymentStatus == PaymentStatus.waiting) {
        _simulateConfirmation();
      }
    });
  }

  Future<void> _simulateConfirmation() async {
    final provider = context.read<PaymentsProvider>();
    await provider.simulateBlockchainConfirmation();

    // Stop pulse and start check animation
    _pulseController.stop();
    _checkController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Payment',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () {
            context.read<PaymentsProvider>().cancelPayment();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<PaymentsProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Amount Display
                  _buildAmountSection(context, provider),

                  const SizedBox(height: 24),

                  // Payment Progress Steps
                  _buildPaymentSteps(context, provider),

                  const SizedBox(height: 24),

                  // Payment Status Section
                  Expanded(child: _buildPaymentStatusSection(context, provider)),

                  // Action Buttons
                  _buildActionButtons(context, provider),
                ],
              ),
          );
        },
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Amount to Pay',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.amount.toStringAsFixed(2)}',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              fontSize: 36,
            ),
          ),
          if (widget.network != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.network!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSteps(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define payment steps
    final steps = [
      'Payment Initiated',
      'QR Code Generated',
      'Waiting for Payment',
      'Blockchain Confirmation',
      'Payment Complete',
    ];

    // Determine current step based on payment status
    int currentStep = 0;
    switch (provider.paymentStatus) {
      case PaymentStatus.idle:
        currentStep = 0;
        break;
      case PaymentStatus.waiting:
        currentStep = 2; // QR code is generated and waiting
        break;
      case PaymentStatus.confirmed:
        currentStep = 4; // Payment complete
        break;
      case PaymentStatus.cancelled:
      case PaymentStatus.failed:
        currentStep = 2; // Show as waiting step
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          StepBar(
            steps: steps.map((step) => StepBarStep(
              title: step,
              isCompleted: steps.indexOf(step) < currentStep,
              isActive: steps.indexOf(step) == currentStep,
            )).toList(),
            currentStep: currentStep,
            completedColor: colorScheme.primary,
            activeColor: colorScheme.primary.withOpacity(0.3),
            inactiveColor: colorScheme.onSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusSection(
    BuildContext context,
    PaymentsProvider provider,
  ) {
    switch (provider.paymentStatus) {
      case PaymentStatus.waiting:
        return _buildWaitingState(context, provider);
      case PaymentStatus.confirmed:
        return _buildConfirmedState(context, provider);
      case PaymentStatus.cancelled:
        return _buildCancelledState(context, provider);
      case PaymentStatus.failed:
        return _buildFailedState(context, provider);
      default:
        return _buildIdleState(context, provider);
    }
  }

  Widget _buildWaitingState(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated QR Code
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: provider.paymentId ?? '',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // Status Text
        Text(
          'Waiting for Payment...',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Scan QR code to complete payment',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 16),

        // Payment ID
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Payment ID: ${provider.paymentId ?? ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontFamily: 'monospace',
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Loading Indicator
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedState(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Animation
        AnimatedBuilder(
          animation: _checkAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _checkAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.check,
                  size: 60,
                  color: colorScheme.onPrimary,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // Success Text
        Text(
          'Payment Confirmed ✅',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Transaction completed successfully',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),

        const SizedBox(height: 24),

        // Transaction Details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Amount',
                '\$${widget.amount.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Payment ID', provider.paymentId ?? ''),
              if (provider.blockchainTxId != null)
                _buildDetailRow('Transaction ID', provider.blockchainTxId!),
              _buildDetailRow('Status', 'Completed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontFamily: label == 'Transaction ID' ? 'monospace' : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledState(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.cancel_outlined,
            size: 60,
            color: colorScheme.onErrorContainer,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Payment Cancelled',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.error,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Payment was cancelled by user',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedState(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.error_outline,
            size: 60,
            color: colorScheme.onErrorContainer,
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Payment Failed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.error,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          provider.error ?? 'An error occurred during payment',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIdleState(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.payment,
            size: 60,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),

        const SizedBox(height: 32),

        Text(
          'Preparing Payment...',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Please wait while we set up your payment',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, PaymentsProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        if (provider.paymentStatus == PaymentStatus.waiting) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                provider.cancelPayment();
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.cancel_outlined,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              label: Text(
                'Cancel Payment',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ] else if (provider.paymentStatus == PaymentStatus.confirmed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.resetPayment();
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.done, color: colorScheme.onPrimary),
              label: Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ] else if (provider.paymentStatus == PaymentStatus.failed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.resetPayment();
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
              label: Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
