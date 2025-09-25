/// Base class for all failures in the app
abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}
