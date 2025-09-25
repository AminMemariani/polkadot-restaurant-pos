import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  final String restaurantName;
  final String currency;
  final double taxRate;
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;

  const Settings({
    required this.restaurantName,
    required this.currency,
    required this.taxRate,
    required this.darkMode,
    required this.language,
    required this.notificationsEnabled,
  });

  @override
  List<Object?> get props => [
    restaurantName,
    currency,
    taxRate,
    darkMode,
    language,
    notificationsEnabled,
  ];
}
