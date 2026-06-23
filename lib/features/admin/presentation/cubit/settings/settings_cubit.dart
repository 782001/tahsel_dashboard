import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_settings.dart';
import 'package:tahsel_dashboard/features/admin/domain/repositories/admin_repository.dart'
    show ReleasePlatform;
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetAppSettingsUseCase getSettings,
    required UpdateAppSettingsUseCase updateSettings,
    required UpdatePlatformReleaseUseCase updatePlatformRelease,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings,
        _updatePlatformRelease = updatePlatformRelease,
        super(SettingsInitial());

  final GetAppSettingsUseCase _getSettings;
  final UpdateAppSettingsUseCase _updateSettings;
  final UpdatePlatformReleaseUseCase _updatePlatformRelease;

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
      (_) {
        emit(SettingsSaved());
        load();
      },
    );
  }

  Future<void> savePlatformRelease(
    ReleasePlatform platform,
    PlatformRelease release,
  ) async {
    // 1. Emit the specific platform saving state
    switch (platform) {
      case ReleasePlatform.android:
        emit(SettingsSavingAndroid());
        break;
      case ReleasePlatform.ios:
        emit(SettingsSavingIos());
        break;
      case ReleasePlatform.windows:
        emit(SettingsSavingWindows());
        break;
    }

    final result = await _updatePlatformRelease(
      UpdatePlatformReleaseParams(platform: platform, release: release),
    );

    result.fold(
      (f) => emit(SettingsError(f.message)),
      (_) {
        // 2. Emit the specific platform saved state
        switch (platform) {
          case ReleasePlatform.android:
            emit(SettingsSavedAndroid());
            break;
          case ReleasePlatform.ios:
            emit(SettingsSavedIos());
            break;
          case ReleasePlatform.windows:
            emit(SettingsSavedWindows());
            break;
        }
        // 3. Reload settings from source to ensure state is fresh and UI is in sync
        load();
      },
    );
  }
}
