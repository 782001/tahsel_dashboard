import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String minSupportedVersion;
  final String latestVersion;
  final bool forceUpdate;

  const AppSettings({
    this.minSupportedVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.forceUpdate = false,
  });

  @override
  List<Object?> get props => [minSupportedVersion, latestVersion, forceUpdate];
}
