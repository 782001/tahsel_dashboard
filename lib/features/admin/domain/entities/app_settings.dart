import 'package:equatable/equatable.dart';

// ─── Per-platform release config ─────────────────────────────────────────────

class PlatformRelease extends Equatable {
  final String versionName;
  final int buildNumber;
  final String downloadUrl;
  final bool forceUpdate;
  final String updateTitle;
  final String updateMessage;
  final String releaseNotes;

  const PlatformRelease({
    this.versionName = '1.0.0',
    this.buildNumber = 1,
    this.downloadUrl = '',
    this.forceUpdate = false,
    this.updateTitle = '',
    this.updateMessage = '',
    this.releaseNotes = '',
  });

  PlatformRelease copyWith({
    String? versionName,
    int? buildNumber,
    String? downloadUrl,
    bool? forceUpdate,
    String? updateTitle,
    String? updateMessage,
    String? releaseNotes,
  }) {
    return PlatformRelease(
      versionName: versionName ?? this.versionName,
      buildNumber: buildNumber ?? this.buildNumber,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      updateTitle: updateTitle ?? this.updateTitle,
      updateMessage: updateMessage ?? this.updateMessage,
      releaseNotes: releaseNotes ?? this.releaseNotes,
    );
  }

  Map<String, dynamic> toMap() => {
        'versionName': versionName,
        'buildNumber': buildNumber,
        'downloadUrl': downloadUrl,
        'forceUpdate': forceUpdate,
        'updateTitle': updateTitle,
        'updateMessage': updateMessage,
        'releaseNotes': releaseNotes,
      };

  factory PlatformRelease.fromMap(Map<String, dynamic> map) => PlatformRelease(
        versionName: map['versionName'] as String? ?? '1.0.0',
        buildNumber: (map['buildNumber'] as num?)?.toInt() ?? 1,
        downloadUrl: map['downloadUrl'] as String? ??
            map['storeUrl'] as String? ??
            '',
        forceUpdate: map['forceUpdate'] as bool? ?? false,
        updateTitle: map['updateTitle'] as String? ?? '',
        updateMessage: map['updateMessage'] as String? ?? '',
        releaseNotes: map['releaseNotes'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        versionName,
        buildNumber,
        downloadUrl,
        forceUpdate,
        updateTitle,
        updateMessage,
        releaseNotes,
      ];
}

// ─── Top-level settings container ────────────────────────────────────────────

class AppSettings extends Equatable {
  final PlatformRelease android;
  final PlatformRelease ios;
  final PlatformRelease windows;

  const AppSettings({
    this.android = const PlatformRelease(),
    this.ios = const PlatformRelease(),
    this.windows = const PlatformRelease(),
  });

  /// Migration helper: build from the legacy flat structure that may still
  /// exist in Firestore under `app_config/version_control`.
  factory AppSettings.fromLegacy(Map<String, dynamic> data) {
    final legacyVersion = data['version_name'] as String? ?? '1.0.0';
    final legacyBuild = (data['latest_version'] as num?)?.toInt() ?? 1;
    final legacyForce = data['force_update'] as bool? ?? false;
    final legacyMsg = data['update_message'] as String? ?? '';

    // Map the legacy config to Android as the safe fallback, and let the admin
    // configure iOS and Windows independently afterwards.
    final androidFallback = PlatformRelease(
      versionName: legacyVersion,
      buildNumber: legacyBuild,
      downloadUrl: data['android_download_url'] as String? ?? '',
      forceUpdate: legacyForce,
      updateTitle: '',
      updateMessage: legacyMsg,
      releaseNotes: '',
    );
    final iosFallback = PlatformRelease(
      versionName: legacyVersion,
      buildNumber: legacyBuild,
      downloadUrl: data['ios_download_url'] as String? ?? '',
      forceUpdate: legacyForce,
      updateTitle: '',
      updateMessage: legacyMsg,
      releaseNotes: '',
    );
    final windowsFallback = PlatformRelease(
      versionName: legacyVersion,
      buildNumber: legacyBuild,
      downloadUrl: data['windows_download_url'] as String? ?? '',
      forceUpdate: legacyForce,
      updateTitle: '',
      updateMessage: legacyMsg,
      releaseNotes: '',
    );

    return AppSettings(
      android: androidFallback,
      ios: iosFallback,
      windows: windowsFallback,
    );
  }

  AppSettings copyWith({
    PlatformRelease? android,
    PlatformRelease? ios,
    PlatformRelease? windows,
  }) {
    return AppSettings(
      android: android ?? this.android,
      ios: ios ?? this.ios,
      windows: windows ?? this.windows,
    );
  }

  @override
  List<Object?> get props => [android, ios, windows];
}
