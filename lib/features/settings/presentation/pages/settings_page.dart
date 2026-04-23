import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/settings_provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/services/theme_service.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/motion/motion.dart';
import 'package:restaurant_pos_app/shared/utils/app_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _taxRateController = TextEditingController();
  final _serviceFeeRateController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  @override
  void dispose() {
    _taxRateController.dispose();
    _serviceFeeRateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final provider = context.read<SettingsProvider>();
    await provider.loadSettings();

    if (mounted) {
      _taxRateController.text = (provider.taxRate * 100).toStringAsFixed(1);
      _serviceFeeRateController.text = (provider.serviceFeeRate * 100)
          .toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(
          'Settings',
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
          onPressed: () => context.go('/'),
          icon: Icon(AppIcons.arrowBackRounded),
          tooltip: 'Back',
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 32 : 24,
              AppSpacing.appBarOffset(context) + (isTablet ? 32 : 24),
              isTablet ? 32 : 24,
              isTablet ? 32 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(context, isTablet),

                const SizedBox(height: 32),

                // Appearance (light / dark / system)
                _buildAppearanceSection(context, isTablet),

                const SizedBox(height: 32),

                // Tax & Fee Settings
                _buildTaxFeeSection(context, provider, isTablet),

                const SizedBox(height: 32),

                // Blockchain RPC Settings
                _buildBlockchainRpcSection(context, provider, isTablet),

                const SizedBox(height: 32),

                // Data Management Section
                _buildDataManagementSection(context, provider, isTablet),

                const SizedBox(height: 32),

                // App Information Section
                _buildAppInfoSection(context, isTablet),

                if (AppConfig.isSupabaseConfigured) ...[
                  const SizedBox(height: 32),
                  _buildAccountSection(context, isTablet),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final session = Supabase.instance.client.auth.currentSession;
    final email = session?.user.email ?? 'Signed in';

    return GlassCard(
      padding: EdgeInsets.all(isTablet ? AppSpacing.xxl : AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.settingsRounded, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Account',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: Icon(AppIcons.closeRounded),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return GlassCard(
          padding: EdgeInsets.all(isTablet ? AppSpacing.xxl : AppSpacing.xl),
          borderRadius: AppRadius.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    themeService.isDarkMode
                        ? AppIcons.darkMode
                        : AppIcons.lightMode,
                    color: colorScheme.primary,
                    size: isTablet ? 24 : 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _ThemeOptionTile(
                label: 'Light',
                icon: AppIcons.lightMode,
                isSelected: themeService.themeMode == ThemeMode.light,
                onTap: () => themeService.setThemeMode(ThemeMode.light),
                isTablet: isTablet,
              ),
              const SizedBox(height: AppSpacing.md),
              _ThemeOptionTile(
                label: 'Dark',
                icon: AppIcons.darkMode,
                isSelected: themeService.themeMode == ThemeMode.dark,
                onTap: () => themeService.setThemeMode(ThemeMode.dark),
                isTablet: isTablet,
              ),
              const SizedBox(height: AppSpacing.md),
              _ThemeOptionTile(
                label: 'System default',
                icon: AppIcons.settingsRounded,
                isSelected: themeService.themeMode == ThemeMode.system,
                onTap: () => themeService.setThemeMode(ThemeMode.system),
                isTablet: isTablet,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.settingsRounded,
                  color: colorScheme.onPrimary,
                  size: isTablet ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Settings',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure tax rates, service fees, and manage data',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxFeeSection(
    BuildContext context,
    SettingsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      padding: EdgeInsets.all(isTablet ? AppSpacing.xxl : AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.calculateRounded,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Tax & Service Fees',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tax Rate
          _buildSettingField(
            context,
            label: 'Tax Rate (%)',
            controller: _taxRateController,
            icon: AppIcons.receiptLongRounded,
            onChanged: (value) => _updateTaxRate(value),
            isTablet: isTablet,
          ),

          const SizedBox(height: 20),

          // Service Fee Rate
          _buildSettingField(
            context,
            label: 'Service Fee Rate (%)',
            controller: _serviceFeeRateController,
            icon: AppIcons.roomServiceRounded,
            onChanged: (value) => _updateServiceFeeRate(value),
            isTablet: isTablet,
          ),

          const SizedBox(height: 20),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveSettings,
              icon: _isLoading
                  ? SizedBox(
                      width: isTablet ? 20 : 16,
                      height: isTablet ? 20 : 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      AppIcons.saveRounded,
                      size: isTablet ? 20 : 18,
                      color: colorScheme.onPrimary,
                    ),
              label: Text(
                _isLoading ? 'Saving...' : 'Save Settings',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainRpcSection(
    BuildContext context,
    SettingsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      padding: EdgeInsets.all(isTablet ? AppSpacing.xxl : AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.linkRounded,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Blockchain RPC Endpoint',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Polkadot RPC Endpoints
          Text(
            'Polkadot RPC Endpoint',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...AppConstants.polkadotRpcEndpoints.map((endpoint) {
            final isSelected = provider.rpcEndpoint == endpoint;
            return _buildRpcEndpointOption(
              context,
              endpoint: endpoint,
              isSelected: isSelected,
              onTap: () => provider.updateRpcEndpoint(endpoint),
              isTablet: isTablet,
            );
          }),

          const SizedBox(height: 24),

          // Kusama RPC Endpoints
          Text(
            'Kusama RPC Endpoint',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...AppConstants.kusamaRpcEndpoints.map((endpoint) {
            final isSelected = provider.kusamaRpcEndpoint == endpoint;
            return _buildRpcEndpointOption(
              context,
              endpoint: endpoint,
              isSelected: isSelected,
              onTap: () => provider.updateKusamaRpcEndpoint(endpoint),
              isTablet: isTablet,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRpcEndpointOption(
    BuildContext context, {
    required String endpoint,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(isTablet ? AppSpacing.lg : AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? AppIcons.radioButtonChecked
                    : AppIcons.radioButtonUnchecked,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  endpoint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  AppIcons.checkCircleRounded,
                  color: colorScheme.primary,
                  size: isTablet ? 20 : 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Function(String) onChanged,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          prefixIcon: Icon(
            icon,
            color: colorScheme.primary,
            size: isTablet ? 24 : 20,
          ),
          suffixText: '%',
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(
    BuildContext context,
    SettingsProvider provider,
    bool isTablet,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      padding: EdgeInsets.all(isTablet ? AppSpacing.xxl : AppSpacing.xl),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.storageRounded,
                color: colorScheme.secondary,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Data Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Clear Products Button
          _buildActionButton(
            context,
            label: 'Clear Product Catalog',
            description: 'Remove all products from the catalog',
            icon: AppIcons.inventory2Outlined,
            color: colorScheme.tertiary,
            onPressed: () => _showClearProductsDialog(context),
            isTablet: isTablet,
          ),

          const SizedBox(height: 16),

          // Clear Receipts Button
          _buildActionButton(
            context,
            label: 'Clear Receipt History',
            description: 'Remove all saved receipts',
            icon: AppIcons.receiptLongOutlined,
            color: colorScheme.error,
            onPressed: () => _showClearReceiptsDialog(context),
            isTablet: isTablet,
          ),

          const SizedBox(height: 16),

          // Clear All Data Button
          _buildActionButton(
            context,
            label: 'Clear All Data',
            description: 'Remove all products, receipts, and settings',
            icon: AppIcons.deleteForeverOutlined,
            color: colorScheme.error,
            onPressed: () => _showClearAllDataDialog(context),
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: isTablet ? 20 : 18),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.infoOutlineRounded,
                color: colorScheme.onSurfaceVariant,
                size: isTablet ? 24 : 20,
              ),
              const SizedBox(width: 12),
              Text(
                'App Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Version', '1.0.0', isTablet),
          _buildInfoRow('Build', '1', isTablet),
          _buildInfoRow('Platform', 'Flutter', isTablet),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _updateTaxRate(String value) {
    // Real-time validation could be added here
  }

  void _updateServiceFeeRate(String value) {
    // Real-time validation could be added here
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<SettingsProvider>();
      final taxRate = double.tryParse(_taxRateController.text) ?? 0.0;
      final serviceFeeRate =
          double.tryParse(_serviceFeeRateController.text) ?? 0.0;

      await provider.updateTaxRate(taxRate / 100);
      await provider.updateServiceFeeRate(serviceFeeRate / 100);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
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

  Future<void> _showClearProductsDialog(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GlassDialog(
        title: const Text('Clear Product Catalog'),
        content: const Text(
          'Are you sure you want to clear all products? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearProducts();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Product catalog cleared')),
      );
    }
  }

  Future<void> _showClearReceiptsDialog(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GlassDialog(
        title: const Text('Clear Receipt History'),
        content: const Text(
          'Are you sure you want to clear all receipts? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearReceipts();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Receipt history cleared')),
      );
    }
  }

  Future<void> _showClearAllDataDialog(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GlassDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all data? This will remove all products, receipts, and reset settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearAllData();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('All data cleared')));
      _loadSettings();
    }
  }
}

/// Single tappable row in the appearance picker. Same pattern as the RPC
/// endpoint selector — animated container, primary tint when selected.
class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(isTablet ? AppSpacing.lg : AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                AppIcons.checkCircleRounded,
                color: colorScheme.primary,
                size: isTablet ? 20 : 18,
              ),
          ],
        ),
      ),
    );
  }
}
