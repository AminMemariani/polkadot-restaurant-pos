import 'dart:async';
import 'package:flutter/material.dart';

/// Abstract feature manager for handling feature flags and modular architecture
abstract class FeatureManager {
  /// Initialize feature manager
  Future<void> initialize();

  /// Check if a feature is enabled
  bool isFeatureEnabled(String featureName);

  /// Enable a feature
  Future<void> enableFeature(String featureName);

  /// Disable a feature
  Future<void> disableFeature(String featureName);

  /// Get all available features
  List<Feature> getAvailableFeatures();

  /// Get enabled features
  List<Feature> getEnabledFeatures();

  /// Register a new feature
  Future<void> registerFeature(Feature feature);

  /// Get feature configuration
  FeatureConfiguration? getFeatureConfiguration(String featureName);

  /// Update feature configuration
  Future<void> updateFeatureConfiguration(
    String featureName,
    FeatureConfiguration config,
  );

  /// Get feature dependencies
  List<String> getFeatureDependencies(String featureName);

  /// Check feature compatibility
  bool isFeatureCompatible(String featureName, String targetFeature);
}

/// Feature definition
class Feature {
  final String name;
  final String description;
  final String version;
  final List<String> dependencies;
  final FeatureType type;
  final bool isEnabled;
  final Map<String, dynamic> configuration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Feature({
    required this.name,
    required this.description,
    required this.version,
    required this.dependencies,
    required this.type,
    required this.isEnabled,
    required this.configuration,
    required this.createdAt,
    this.updatedAt,
  });

  Feature copyWith({
    String? name,
    String? description,
    String? version,
    List<String>? dependencies,
    FeatureType? type,
    bool? isEnabled,
    Map<String, dynamic>? configuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feature(
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      dependencies: dependencies ?? this.dependencies,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      configuration: configuration ?? this.configuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Feature type enum
enum FeatureType {
  core,
  payment,
  analytics,
  inventory,
  customer,
  reporting,
  integration,
  ui,
}

/// Feature configuration
class FeatureConfiguration {
  final Map<String, dynamic> settings;
  final List<String> enabledSubFeatures;
  final Map<String, dynamic> customProperties;

  const FeatureConfiguration({
    required this.settings,
    required this.enabledSubFeatures,
    required this.customProperties,
  });
}

/// Feature dependency resolver
class FeatureDependencyResolver {
  static List<String> resolveDependencies(
    List<Feature> features,
    String targetFeature,
  ) {
    final resolved = <String>{};
    final toResolve = <String>[targetFeature];

    while (toResolve.isNotEmpty) {
      final current = toResolve.removeAt(0);
      if (resolved.contains(current)) continue;

      final feature = features.firstWhere(
        (f) => f.name == current,
        orElse: () => throw Exception('Feature not found: $current'),
      );

      resolved.add(current);
      toResolve.addAll(feature.dependencies);
    }

    return resolved.toList()..remove(targetFeature);
  }

  static bool hasCircularDependency(List<Feature> features) {
    final visited = <String>{};
    final recursionStack = <String>{};

    for (final feature in features) {
      if (_hasCircularDependencyDFS(
        feature.name,
        features,
        visited,
        recursionStack,
      )) {
        return true;
      }
    }

    return false;
  }

  static bool _hasCircularDependencyDFS(
    String featureName,
    List<Feature> features,
    Set<String> visited,
    Set<String> recursionStack,
  ) {
    if (recursionStack.contains(featureName)) {
      return true;
    }

    if (visited.contains(featureName)) {
      return false;
    }

    visited.add(featureName);
    recursionStack.add(featureName);

    final feature = features.firstWhere(
      (f) => f.name == featureName,
      orElse: () => throw Exception('Feature not found: $featureName'),
    );

    for (final dependency in feature.dependencies) {
      if (_hasCircularDependencyDFS(
        dependency,
        features,
        visited,
        recursionStack,
      )) {
        return true;
      }
    }

    recursionStack.remove(featureName);
    return false;
  }
}

/// Mock implementation for development/testing
class MockFeatureManager implements FeatureManager {
  final Map<String, Feature> _features = {};
  final Map<String, FeatureConfiguration> _configurations = {};

  MockFeatureManager() {
    _initializeDefaultFeatures();
  }

  @override
  Future<void> initialize() async {
    // Simulate initialization
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  bool isFeatureEnabled(String featureName) {
    final feature = _features[featureName];
    return feature?.isEnabled ?? false;
  }

  @override
  Future<void> enableFeature(String featureName) async {
    final feature = _features[featureName];
    if (feature != null) {
      _features[featureName] = feature.copyWith(
        isEnabled: true,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> disableFeature(String featureName) async {
    final feature = _features[featureName];
    if (feature != null) {
      _features[featureName] = feature.copyWith(
        isEnabled: false,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  List<Feature> getAvailableFeatures() {
    return _features.values.toList();
  }

  @override
  List<Feature> getEnabledFeatures() {
    return _features.values.where((feature) => feature.isEnabled).toList();
  }

  @override
  Future<void> registerFeature(Feature feature) async {
    _features[feature.name] = feature;

    // Initialize default configuration
    _configurations[feature.name] = FeatureConfiguration(
      settings: feature.configuration,
      enabledSubFeatures: [],
      customProperties: {},
    );
  }

  @override
  FeatureConfiguration? getFeatureConfiguration(String featureName) {
    return _configurations[featureName];
  }

  @override
  Future<void> updateFeatureConfiguration(
    String featureName,
    FeatureConfiguration config,
  ) async {
    _configurations[featureName] = config;
  }

  @override
  List<String> getFeatureDependencies(String featureName) {
    final feature = _features[featureName];
    if (feature == null) return [];

    return FeatureDependencyResolver.resolveDependencies(
      _features.values.toList(),
      featureName,
    );
  }

  @override
  bool isFeatureCompatible(String featureName, String targetFeature) {
    final feature = _features[featureName];
    final target = _features[targetFeature];

    if (feature == null || target == null) return false;

    // Check if target feature is in dependencies
    return feature.dependencies.contains(targetFeature);
  }

  void _initializeDefaultFeatures() {
    final defaultFeatures = [
      Feature(
        name: 'products',
        description: 'Product catalog management',
        version: '1.0.0',
        dependencies: [],
        type: FeatureType.core,
        isEnabled: true,
        configuration: {
          'maxProducts': 1000,
          'allowCategories': true,
          'requireImages': false,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'receipts',
        description: 'Receipt and order management',
        version: '1.0.0',
        dependencies: ['products'],
        type: FeatureType.core,
        isEnabled: true,
        configuration: {
          'autoSave': true,
          'maxItemsPerOrder': 100,
          'allowModifications': true,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'payments',
        description: 'Payment processing',
        version: '1.0.0',
        dependencies: ['receipts'],
        type: FeatureType.payment,
        isEnabled: true,
        configuration: {
          'supportedMethods': ['cash', 'card', 'blockchain'],
          'requireConfirmation': true,
          'autoProcess': false,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'blockchain_payments',
        description: 'Blockchain payment integration',
        version: '1.0.0',
        dependencies: ['payments'],
        type: FeatureType.payment,
        isEnabled: false, // Disabled by default
        configuration: {
          'supportedNetworks': ['polkadot', 'kusama'],
          'testnetMode': true,
          'autoConfirm': false,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'analytics',
        description: 'Sales analytics and reporting',
        version: '1.0.0',
        dependencies: ['receipts', 'payments'],
        type: FeatureType.analytics,
        isEnabled: true,
        configuration: {
          'trackSales': true,
          'trackProducts': true,
          'trackPayments': true,
          'retentionDays': 365,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'inventory',
        description: 'Inventory management',
        version: '1.0.0',
        dependencies: ['products'],
        type: FeatureType.inventory,
        isEnabled: false, // Disabled by default
        configuration: {
          'trackStock': true,
          'lowStockAlert': 10,
          'autoReorder': false,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'customer_management',
        description: 'Customer information and loyalty',
        version: '1.0.0',
        dependencies: ['receipts'],
        type: FeatureType.customer,
        isEnabled: false, // Disabled by default
        configuration: {
          'requireCustomerInfo': false,
          'loyaltyProgram': false,
          'customerHistory': true,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'multi_language',
        description: 'Multi-language support',
        version: '1.0.0',
        dependencies: [],
        type: FeatureType.ui,
        isEnabled: true,
        configuration: {
          'supportedLanguages': ['en', 'es', 'fr'],
          'defaultLanguage': 'en',
          'autoDetect': true,
        },
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'dark_mode',
        description: 'Dark mode theme support',
        version: '1.0.0',
        dependencies: [],
        type: FeatureType.ui,
        isEnabled: true,
        configuration: {'autoSwitch': false, 'systemTheme': true},
        createdAt: DateTime.now(),
      ),
      Feature(
        name: 'advanced_reporting',
        description: 'Advanced reporting and exports',
        version: '1.0.0',
        dependencies: ['analytics'],
        type: FeatureType.reporting,
        isEnabled: false, // Disabled by default
        configuration: {
          'exportFormats': ['csv', 'json', 'pdf'],
          'scheduledReports': false,
          'emailReports': false,
        },
        createdAt: DateTime.now(),
      ),
    ];

    for (final feature in defaultFeatures) {
      _features[feature.name] = feature;
      _configurations[feature.name] = FeatureConfiguration(
        settings: feature.configuration,
        enabledSubFeatures: [],
        customProperties: {},
      );
    }
  }
}

/// Feature toggle widget for UI
class FeatureToggle extends StatelessWidget {
  final String featureName;
  final Widget child;
  final Widget? fallback;

  const FeatureToggle({
    super.key,
    required this.featureName,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // This would be used in UI to conditionally show features
    // Implementation would depend on how you want to access FeatureManager
    return child;
  }
}
