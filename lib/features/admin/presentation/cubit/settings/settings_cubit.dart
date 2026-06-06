import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetAppSettingsUseCase getSettings,
    required UpdateAppSettingsUseCase updateSettings,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings,
        super(SettingsInitial());

  final GetAppSettingsUseCase _getSettings;
  final UpdateAppSettingsUseCase _updateSettings;

  Future<void> load() async {
    emit(SettingsLoading());
    final result = await _getSettings(const NoParams());
    result.fold(
      (f) => emit(SettingsError(f.message)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> save(AppSettings settings) async {
    emit(SettingsSaving());
    final result = await _updateSettings(settings);
    result.fold(
      (f) => emit(SettingsError(f.message)),
      (_) => emit(SettingsSaved()),
    );
  }
}
