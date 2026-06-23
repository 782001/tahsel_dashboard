import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  const SettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsSaving extends SettingsState {}

class SettingsSaved extends SettingsState {}

/// Granular saving states so the UI can show per-platform loaders.
class SettingsSavingAndroid extends SettingsState {}

class SettingsSavingIos extends SettingsState {}

class SettingsSavingWindows extends SettingsState {}

class SettingsSavedAndroid extends SettingsState {}

class SettingsSavedIos extends SettingsState {}

class SettingsSavedWindows extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
