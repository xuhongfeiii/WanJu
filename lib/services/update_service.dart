import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';

class UpdateInfo {
  final int versionCode;
  final String versionName;
  final String downloadUrl;
  final String changelog;
  final bool forceUpdate;

  UpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.downloadUrl,
    required this.changelog,
    this.forceUpdate = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      versionCode: json['versionCode'] as int,
      versionName: json['versionName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      changelog: json['changelog'] as String? ?? '',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
    );
  }
}

class UpdateService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static Future<UpdateInfo?> checkUpdate() async {
    try {
      final config = await StorageService.loadAppConfig();
      final checkUrl = config['updateCheckUrl'] as String?;
      if (checkUrl == null || checkUrl.isEmpty) return null;

      final response = await _dio.get(checkUrl);
      if (response.statusCode != 200) return null;

      final updateInfo = UpdateInfo.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      final packageInfo = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      if (updateInfo.versionCode > currentCode) {
        return updateInfo;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> downloadApk(
    String url,
    void Function(double progress) onProgress,
  ) async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return null;

      final filePath = '${dir.path}/wanju_update.apk';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );

      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> installApk(String filePath) async {
    await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');
  }
}