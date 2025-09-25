import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../features/products/data/datasources/products_local_datasource.dart';
import '../../features/products/data/datasources/products_remote_datasource.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/add_product.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/presentation/providers/products_provider.dart';

import '../../features/receipts/data/datasources/receipts_local_datasource.dart';
import '../../features/receipts/data/datasources/receipts_remote_datasource.dart';
import '../../features/receipts/data/repositories/receipts_repository_impl.dart';
import '../../features/receipts/domain/repositories/receipts_repository.dart';
import '../../features/receipts/domain/usecases/get_receipts.dart';
import '../../features/receipts/domain/usecases/create_receipt.dart';
import '../../features/receipts/domain/usecases/update_receipt.dart';
import '../../features/receipts/presentation/providers/receipts_provider.dart';

import '../../features/payments/data/datasources/payments_local_datasource.dart';
import '../../features/payments/data/datasources/payments_remote_datasource.dart';
import '../../features/payments/data/repositories/payments_repository_impl.dart';
import '../../features/payments/domain/repositories/payments_repository.dart';
import '../../features/payments/domain/usecases/process_payment.dart';
import '../../features/payments/domain/usecases/get_payment_methods.dart';
import '../../features/payments/presentation/providers/payments_provider.dart';

import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_settings.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

import '../network/network_info.dart';
import '../network/api_client.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiClient(sl()));

  // Features - Products
  _initProducts();

  // Features - Receipts
  _initReceipts();

  // Features - Payments
  _initPayments();

  // Features - Settings
  _initSettings();
}

void _initProducts() {
  // Data sources
  sl.registerLazySingleton<ProductsLocalDataSource>(
    () => ProductsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // Provider
  sl.registerFactory(
    () => ProductsProvider(
      getProducts: sl(),
      addProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
    ),
  );
}

void _initReceipts() {
  // Data sources
  sl.registerLazySingleton<ReceiptsLocalDataSource>(
    () => ReceiptsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ReceiptsRemoteDataSource>(
    () => ReceiptsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ReceiptsRepository>(
    () => ReceiptsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetReceipts(sl()));
  sl.registerLazySingleton(() => CreateReceipt(sl()));
  sl.registerLazySingleton(() => UpdateReceipt(sl()));

  // Provider
  sl.registerFactory(
    () => ReceiptsProvider(
      getReceipts: sl(),
      createReceipt: sl(),
      updateReceipt: sl(),
    ),
  );
}

void _initPayments() {
  // Data sources
  sl.registerLazySingleton<PaymentsLocalDataSource>(
    () => PaymentsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PaymentsRemoteDataSource>(
    () => PaymentsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ProcessPayment(sl()));
  sl.registerLazySingleton(() => GetPaymentMethods(sl()));

  // Provider
  sl.registerFactory(
    () => PaymentsProvider(processPayment: sl(), getPaymentMethods: sl()),
  );
}

void _initSettings() {
  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateSettings(sl()));

  // Provider
  sl.registerFactory(
    () => SettingsProvider(getSettings: sl(), updateSettings: sl()),
  );
}
