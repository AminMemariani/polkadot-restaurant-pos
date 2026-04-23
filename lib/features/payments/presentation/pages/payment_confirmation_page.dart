import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:step_bar/step_bar.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/motion/motion.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_progress.dart';
import '../../domain/entities/payment_result.dart';
import '../providers/payments_provider.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

/// Renders the in-flight payment for whichever processor [PaymentsProvider]
/// is currently driving. Pure presentation — pattern-matches on
/// `provider.progress` events and reflects the current rail's UX.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final Animation<double> _checkAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _checkController, curve: Curves.elasticOut));

  bool _checkAnimationStarted = false;

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(
          'Payment Confirmation',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.read<PaymentsProvider>().cancel();
            Navigator.of(context).pop();
          },
          icon: Icon(AppIcons.closeRounded),
          tooltip: 'Cancel',
        ),
      ),
      body: Consumer<PaymentsProvider>(
        builder: (context, provider, _) {
          final progress = provider.progress;
          if (progress is PaymentSucceeded && !_checkAnimationStarted) {
            _checkAnimationStarted = true;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _checkController.forward());
          }
          // Page itself scrolls. No Expanded — every section renders at
          // its natural height, so no inner scroll contexts are needed.
          // ConstrainedBox keeps the layout looking centered when content
          // is shorter than the viewport.
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 32 : 24,
                  AppSpacing.appBarOffset(context) + (isTablet ? 32 : 24),
                  isTablet ? 32 : 24,
                  isTablet ? 32 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight -
                        AppSpacing.appBarOffset(context) -
                        (isTablet ? 64 : 48),
                  ),
                  child: Column(
                    children: [
                      _AmountSection(
                        amount: widget.amount,
                        network: widget.network,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _StepsSection(progress: progress),
                      const SizedBox(height: AppSpacing.xxl),
                      _StatusSection(
                        progress: progress,
                        checkAnimation: _checkAnimation,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _ActionButtons(progress: progress),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout sections
// ---------------------------------------------------------------------------

class _AmountSection extends StatelessWidget {
  const _AmountSection({required this.amount, this.network});

  final double amount;
  final String? network;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Hero(
      tag: 'payment_amount_$amount',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.4),
              colorScheme.primaryContainer.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Amount to Pay',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
                fontSize: isTablet ? 48 : 36,
                letterSpacing: -1.0,
              ),
            ),
            if (network != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  network!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({this.progress});

  final PaymentProgress? progress;

  /// Map progress → 0-based "current" step index used to colour the bar.
  int _currentIndex() {
    return switch (progress) {
      PaymentCreating() => 0,
      PaymentAwaitingUser() => 2,
      PaymentProcessing() => 3,
      PaymentSucceeded() => 4,
      PaymentFailed() || PaymentCancelled() => 2,
      _ => 0,
    };
  }

  /// Build the steps with per-step status — the package now requires status
  /// on each StepBarStep instead of a separate currentStep argument.
  List<StepBarStep> _buildSteps() {
    const labels = [
      'Initiated',
      'QR Generated',
      'Awaiting Payment',
      'Confirming',
      'Complete',
    ];
    final cur = _currentIndex();
    return List.generate(labels.length, (i) {
      final StepStatus status;
      if (i < cur) {
        status = StepStatus.completed;
      } else if (i == cur) {
        status = StepStatus.active;
      } else {
        status = StepStatus.inactive;
      }
      return StepBarStep(label: labels[i], status: status);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
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
          const SizedBox(height: AppSpacing.lg),
          StepBar(
            steps: _buildSteps(),
            completedColor: colorScheme.primary,
            activeColor: colorScheme.primary.withValues(alpha: 0.3),
            inactiveColor: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.progress,
    required this.checkAnimation,
  });

  final PaymentProgress? progress;
  final Animation<double> checkAnimation;

  @override
  Widget build(BuildContext context) {
    return switch (progress) {
      PaymentCreating() || null => const _IdleState(),
      PaymentAwaitingUser(:final hint, :final qrData) =>
        _AwaitingState(hint: hint, qrData: qrData),
      PaymentProcessing(:final hint) => _ProcessingState(hint: hint),
      PaymentSucceeded(:final result) => _SuccessState(
          result: result,
          checkAnimation: checkAnimation,
        ),
      PaymentFailed(:final message) => _FailureState(message: message),
      PaymentCancelled() => const _CancelledState(),
    };
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();

  @override
  Widget build(BuildContext context) {
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
            AppIcons.payment,
            size: 60,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          'Preparing Payment...',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _AwaitingState extends StatelessWidget {
  const _AwaitingState({this.hint, this.qrData});
  final String? hint;
  final String? qrData;

  bool _isBlockchain(PaymentMethod? method) =>
      method == PaymentMethod.polkadot || method == PaymentMethod.kusama;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<PaymentsProvider>();
    final method = provider.activeProcessor?.method;
    // Prefer the rich qrData payload from the processor; fall back to the
    // raw payment id for older processors that don't supply one.
    final qrPayload = qrData ??
        provider.lastResult?.providerPaymentId ??
        provider.activeRequest?.orderId ??
        '';

    final centerWidget = _isBlockchain(method)
        ? _QrCard(paymentId: qrPayload)
        : _PulsingIcon(method: method);

    // Page-level scroll handles overflow now; render at natural height.
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        centerWidget,
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          hint ?? 'Waiting for payment...',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
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
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.paymentId});
  final String paymentId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTablet = MediaQuery.of(context).size.width > 768;
    return PulseScale(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: QrImageView(
          data: paymentId,
          version: QrVersions.auto,
          size: isTablet ? 240.0 : 200.0,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatelessWidget {
  const _PulsingIcon({this.method});
  final PaymentMethod? method;

  IconData _iconFor(PaymentMethod? m) {
    return switch (m) {
      PaymentMethod.stripeCard => AppIcons.creditCard,
      PaymentMethod.stripeTerminal => AppIcons.payment,
      _ => AppIcons.payment,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PulseScale(
      enabled: true,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Icon(
          _iconFor(method),
          size: 60,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _ProcessingState extends StatelessWidget {
  const _ProcessingState({this.hint});
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          hint ?? 'Processing...',
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.result, required this.checkAnimation});

  final PaymentResult result;
  final Animation<double> checkAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: checkAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              AppIcons.check,
              size: 60,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          'Payment Confirmed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _TransactionDetails(result: result),
      ],
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({required this.result});
  final PaymentResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final txId = result.raw['blockchain_tx_id'] as String?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
          const SizedBox(height: AppSpacing.md),
          _row(context, 'Amount',
              '\$${result.amountCharged.toMajor().toStringAsFixed(2)}'),
          _row(context, 'Payment ID', result.providerPaymentId),
          if (txId != null) _row(context, 'Transaction ID', txId, mono: true),
          _row(context, 'Status', 'Completed'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool mono = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontFamily: mono ? 'monospace' : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureState extends StatelessWidget {
  const _FailureState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
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
            AppIcons.errorOutline,
            size: 60,
            color: colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          'Payment Failed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.error,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CancelledState extends StatelessWidget {
  const _CancelledState();

  @override
  Widget build(BuildContext context) {
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
            AppIcons.cancelOutlined,
            size: 60,
            color: colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          'Payment Cancelled',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.error,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.progress});
  final PaymentProgress? progress;

  @override
  Widget build(BuildContext context) {
    final isAwaiting =
        progress is PaymentAwaitingUser || progress is PaymentProcessing;
    final isSucceeded = progress is PaymentSucceeded;
    final isFailed = progress is PaymentFailed;

    if (isAwaiting) {
      return _CancelButton();
    }
    if (isSucceeded) {
      return _DoneButton();
    }
    if (isFailed) {
      return _RetryButton();
    }
    return const SizedBox.shrink();
  }
}

class _CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<PaymentsProvider>().cancel();
          Navigator.of(context).pop();
        },
        icon: Icon(AppIcons.cancelOutlined),
        label: const Text('Cancel Payment'),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          context.read<PaymentsProvider>().reset();
          Navigator.of(context).pop();
        },
        icon: Icon(AppIcons.done),
        label: const Text('Done'),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          context.read<PaymentsProvider>().reset();
          Navigator.of(context).pop();
        },
        icon: Icon(AppIcons.refresh),
        label: const Text('Try Again'),
      ),
    );
  }
}
