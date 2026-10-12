import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InstalledAppVersion {
  const InstalledAppVersion({required this.version, required this.build});
  final String version;
  final String build;
}

class AppVersionStatus {
  const AppVersionStatus({
    required this.updateAvailable,
    required this.updateRequired,
    required this.message,
    this.latestVersion,
    this.downloadUrl,
  });

  final bool updateAvailable;
  final bool updateRequired;
  final String message;
  final String? latestVersion;
  final String? downloadUrl;

  factory AppVersionStatus.fromJson(Map<String, dynamic> json) =>
      AppVersionStatus(
        updateAvailable: json['updateAvailable'] == true,
        updateRequired: json['updateRequired'] == true,
        message: json['message']?.toString() ?? 'Hay una actualización disponible.',
        latestVersion: json['latestVersion']?.toString(),
        downloadUrl: json['downloadUrl']?.toString(),
      );
}

class AppVersionService {
  AppVersionService(this._apiClient);
  final ApiClient _apiClient;
  static Future<InstalledAppVersion>? _installed;

  Future<InstalledAppVersion> installed() => _installed ??= _loadInstalled();

  Future<InstalledAppVersion> _loadInstalled() async {
    final info = await PackageInfo.fromPlatform();
    return InstalledAppVersion(version: info.version, build: info.buildNumber);
  }

  Future<AppVersionStatus> check() async {
    final response = await _apiClient.dio.get(
      '/app-version/check',
      options: Options(extra: {'requiresAuth': false}),
    );
    final body = response.data as Map<String, dynamic>;
    return AppVersionStatus.fromJson(body['data'] as Map<String, dynamic>);
  }
}
