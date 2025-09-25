import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, Settings>> updateSettings(Settings settings);
}
