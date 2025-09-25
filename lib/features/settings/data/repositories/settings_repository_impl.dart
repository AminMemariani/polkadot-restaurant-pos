import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Settings>> updateSettings(Settings settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      final updatedSettings = await localDataSource.updateSettings(
        settingsModel,
      );
      return Right(updatedSettings.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
