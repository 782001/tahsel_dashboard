import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String androidDownloadUrl;
  final String windowsDownloadUrl;
  final String iosDownloadUrl;
  final int latestVersion;
  final String versionName;
  final bool forceUpdate;
  final String updateMessage;

  const AppSettings({
    this.androidDownloadUrl = '',
    this.windowsDownloadUrl = '',
    this.iosDownloadUrl = '',
    this.latestVersion = 1,
    this.versionName = '1.0.0',
    this.forceUpdate = false,
    this.updateMessage = '',
  });

  @override
  List<Object?> get props => [
        androidDownloadUrl,
        windowsDownloadUrl,
        iosDownloadUrl,
        latestVersion,
        versionName,
        forceUpdate,
        updateMessage,
      ];
}
