import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/utils/app_icons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/motion/motion.dart';
import '../providers/receipts_provider.dart';

/// Two side-by-side cards at the top of the receipt screen showing the
/// table number and serve-at time for the current order. Tap either to edit.
///
/// These values are optional (null = take-out / serve immediately) so the
/// app keeps working as a counter POS for venues that don't use tables.
class OrderContextBar extends StatelessWidget {
  const OrderContextBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReceiptsProvider>();
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppSpacing.xxl : AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ContextTile(
              icon: AppIcons.restaurant,
              label: 'Table',
              value: provider.tableNumber == null
                  ? 'Set table'
                  : '#${provider.tableNumber}',
              onTap: () => _showTableDialog(context, provider),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ContextTile(
              icon: AppIcons.dateRangeRounded,
              label: 'Serve at',
              value: provider.serveAt == null
                  ? 'Now'
                  : DateFormat('MMM d, h:mm a').format(provider.serveAt!),
              onTap: () => _showServeAtDialog(context, provider),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTableDialog(
    BuildContext context,
    ReceiptsProvider provider,
  ) async {
    final controller = TextEditingController(
      text: provider.tableNumber?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<int?>(
      context: context,
      builder: (context) => GlassDialog(
        title: const Text('Table Number'),
        content: Form(
          key: formKey,
          child: AppTextField(
            controller: controller,
            label: 'Table number',
            hint: 'e.g. 5',
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) {
              if (v == null || v.isEmpty) return null; // empty = clear
              final n = int.tryParse(v);
              if (n == null || n <= 0) return 'Enter a positive number';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          if (provider.tableNumber != null)
            TextButton(
              onPressed: () => Navigator.pop(context, -1),
              child: const Text('Clear'),
            ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final v = controller.text.trim();
              Navigator.pop(context, v.isEmpty ? -1 : int.parse(v));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;
    provider.setTableNumber(result == -1 ? null : result);
  }

  Future<void> _showServeAtDialog(
    BuildContext context,
    ReceiptsProvider provider,
  ) async {
    final initial = provider.serveAt ??
        DateTime.now().add(const Duration(minutes: 30));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !context.mounted) return;

    provider.setServeAt(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

class _ContextTile extends StatelessWidget {
  const _ContextTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PressableScale(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.md,
        elevation: 2,
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.editRounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

