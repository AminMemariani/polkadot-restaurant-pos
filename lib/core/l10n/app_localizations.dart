import 'package:flutter/material.dart';

/// Application localizations for multi-language support
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common
  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;

  // Products
  String get products => _localizedValues[locale.languageCode]!['products']!;
  String get productName =>
      _localizedValues[locale.languageCode]!['productName']!;
  String get productPrice =>
      _localizedValues[locale.languageCode]!['productPrice']!;
  String get addProduct =>
      _localizedValues[locale.languageCode]!['addProduct']!;
  String get editProduct =>
      _localizedValues[locale.languageCode]!['editProduct']!;
  String get deleteProduct =>
      _localizedValues[locale.languageCode]!['deleteProduct']!;
  String get noProducts =>
      _localizedValues[locale.languageCode]!['noProducts']!;
  String get searchProducts =>
      _localizedValues[locale.languageCode]!['searchProducts']!;

  // Receipts
  String get receipts => _localizedValues[locale.languageCode]!['receipts']!;
  String get currentOrder =>
      _localizedValues[locale.languageCode]!['currentOrder']!;
  String get orderSummary =>
      _localizedValues[locale.languageCode]!['orderSummary']!;
  String get subtotal => _localizedValues[locale.languageCode]!['subtotal']!;
  String get tax => _localizedValues[locale.languageCode]!['tax']!;
  String get serviceFee =>
      _localizedValues[locale.languageCode]!['serviceFee']!;
  String get total => _localizedValues[locale.languageCode]!['total']!;
  String get checkout => _localizedValues[locale.languageCode]!['checkout']!;
  String get clearOrder =>
      _localizedValues[locale.languageCode]!['clearOrder']!;

  // Payments
  String get payments => _localizedValues[locale.languageCode]!['payments']!;
  String get paymentMethod =>
      _localizedValues[locale.languageCode]!['paymentMethod']!;
  String get selectPaymentMethod =>
      _localizedValues[locale.languageCode]!['selectPaymentMethod']!;
  String get paymentConfirmation =>
      _localizedValues[locale.languageCode]!['paymentConfirmation']!;
  String get waitingForPayment =>
      _localizedValues[locale.languageCode]!['waitingForPayment']!;
  String get paymentConfirmed =>
      _localizedValues[locale.languageCode]!['paymentConfirmed']!;
  String get paymentFailed =>
      _localizedValues[locale.languageCode]!['paymentFailed']!;
  String get paymentCancelled =>
      _localizedValues[locale.languageCode]!['paymentCancelled']!;

  // Settings
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get taxRate => _localizedValues[locale.languageCode]!['taxRate']!;
  String get serviceFeeRate =>
      _localizedValues[locale.languageCode]!['serviceFeeRate']!;
  String get dataManagement =>
      _localizedValues[locale.languageCode]!['dataManagement']!;
  String get clearProducts =>
      _localizedValues[locale.languageCode]!['clearProducts']!;
  String get clearReceipts =>
      _localizedValues[locale.languageCode]!['clearReceipts']!;
  String get clearAllData =>
      _localizedValues[locale.languageCode]!['clearAllData']!;

  // Analytics
  String get analytics => _localizedValues[locale.languageCode]!['analytics']!;
  String get dailySales =>
      _localizedValues[locale.languageCode]!['dailySales']!;
  String get salesReport =>
      _localizedValues[locale.languageCode]!['salesReport']!;
  String get revenue => _localizedValues[locale.languageCode]!['revenue']!;
  String get transactions =>
      _localizedValues[locale.languageCode]!['transactions']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Restaurant POS',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'confirm': 'Confirm',
      'retry': 'Retry',
      'products': 'Products',
      'productName': 'Product Name',
      'productPrice': 'Price',
      'addProduct': 'Add Product',
      'editProduct': 'Edit Product',
      'deleteProduct': 'Delete Product',
      'noProducts': 'No Products',
      'searchProducts': 'Search Products',
      'receipts': 'Receipts',
      'currentOrder': 'Current Order',
      'orderSummary': 'Order Summary',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'serviceFee': 'Service Fee',
      'total': 'Total',
      'checkout': 'Checkout',
      'clearOrder': 'Clear Order',
      'payments': 'Payments',
      'paymentMethod': 'Payment Method',
      'selectPaymentMethod': 'Select Payment Method',
      'paymentConfirmation': 'Payment Confirmation',
      'waitingForPayment': 'Waiting for Payment...',
      'paymentConfirmed': 'Payment Confirmed',
      'paymentFailed': 'Payment Failed',
      'paymentCancelled': 'Payment Cancelled',
      'settings': 'Settings',
      'taxRate': 'Tax Rate',
      'serviceFeeRate': 'Service Fee Rate',
      'dataManagement': 'Data Management',
      'clearProducts': 'Clear Products',
      'clearReceipts': 'Clear Receipts',
      'clearAllData': 'Clear All Data',
      'analytics': 'Analytics',
      'dailySales': 'Daily Sales',
      'salesReport': 'Sales Report',
      'revenue': 'Revenue',
      'transactions': 'Transactions',
    },
    'es': {
      'appTitle': 'Punto de Venta Restaurante',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'add': 'Agregar',
      'confirm': 'Confirmar',
      'retry': 'Reintentar',
      'products': 'Productos',
      'productName': 'Nombre del Producto',
      'productPrice': 'Precio',
      'addProduct': 'Agregar Producto',
      'editProduct': 'Editar Producto',
      'deleteProduct': 'Eliminar Producto',
      'noProducts': 'Sin Productos',
      'searchProducts': 'Buscar Productos',
      'receipts': 'Recibos',
      'currentOrder': 'Pedido Actual',
      'orderSummary': 'Resumen del Pedido',
      'subtotal': 'Subtotal',
      'tax': 'Impuesto',
      'serviceFee': 'Tarifa de Servicio',
      'total': 'Total',
      'checkout': 'Pagar',
      'clearOrder': 'Limpiar Pedido',
      'payments': 'Pagos',
      'paymentMethod': 'Método de Pago',
      'selectPaymentMethod': 'Seleccionar Método de Pago',
      'paymentConfirmation': 'Confirmación de Pago',
      'waitingForPayment': 'Esperando Pago...',
      'paymentConfirmed': 'Pago Confirmado',
      'paymentFailed': 'Pago Fallido',
      'paymentCancelled': 'Pago Cancelado',
      'settings': 'Configuración',
      'taxRate': 'Tasa de Impuesto',
      'serviceFeeRate': 'Tasa de Tarifa de Servicio',
      'dataManagement': 'Gestión de Datos',
      'clearProducts': 'Limpiar Productos',
      'clearReceipts': 'Limpiar Recibos',
      'clearAllData': 'Limpiar Todos los Datos',
      'analytics': 'Análisis',
      'dailySales': 'Ventas Diarias',
      'salesReport': 'Reporte de Ventas',
      'revenue': 'Ingresos',
      'transactions': 'Transacciones',
    },
    'fr': {
      'appTitle': 'Point de Vente Restaurant',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'cancel': 'Annuler',
      'save': 'Sauvegarder',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'confirm': 'Confirmer',
      'retry': 'Réessayer',
      'products': 'Produits',
      'productName': 'Nom du Produit',
      'productPrice': 'Prix',
      'addProduct': 'Ajouter Produit',
      'editProduct': 'Modifier Produit',
      'deleteProduct': 'Supprimer Produit',
      'noProducts': 'Aucun Produit',
      'searchProducts': 'Rechercher Produits',
      'receipts': 'Reçus',
      'currentOrder': 'Commande Actuelle',
      'orderSummary': 'Résumé de la Commande',
      'subtotal': 'Sous-total',
      'tax': 'Taxe',
      'serviceFee': 'Frais de Service',
      'total': 'Total',
      'checkout': 'Payer',
      'clearOrder': 'Vider la Commande',
      'payments': 'Paiements',
      'paymentMethod': 'Méthode de Paiement',
      'selectPaymentMethod': 'Sélectionner Méthode de Paiement',
      'paymentConfirmation': 'Confirmation de Paiement',
      'waitingForPayment': 'En Attente de Paiement...',
      'paymentConfirmed': 'Paiement Confirmé',
      'paymentFailed': 'Paiement Échoué',
      'paymentCancelled': 'Paiement Annulé',
      'settings': 'Paramètres',
      'taxRate': 'Taux de Taxe',
      'serviceFeeRate': 'Taux de Frais de Service',
      'dataManagement': 'Gestion des Données',
      'clearProducts': 'Vider les Produits',
      'clearReceipts': 'Vider les Reçus',
      'clearAllData': 'Vider Toutes les Données',
      'analytics': 'Analyses',
      'dailySales': 'Ventes Quotidiennes',
      'salesReport': 'Rapport de Ventes',
      'revenue': 'Revenus',
      'transactions': 'Transactions',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
