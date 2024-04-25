// ignore_for_file: invalid_annotation_target

import 'dart:convert';
import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/custom_configs.dart';
import '../di/river_serverpod.dart';

part 'app_sync.freezed.dart';
part 'app_sync.g.dart';

@freezed
sealed class _AppVersionInfo with _$AppVersionInfo {
  const factory _AppVersionInfo({
    @JsonKey(name: 'package_name') required String packageName,
    @JsonKey(name: 'app_name') required String appName,
    required String version,
  }) = __AppVersionInfo;

  factory _AppVersionInfo.fromJson(Map<String, dynamic> json) =>
      _$AppVersionInfoFromJson(json);
}

@Riverpod(keepAlive: true)
class AppSync extends _$AppSync {
  @override
  Future<String?> build() async {
    final exportTo = ref.watch(serverpodProvider).config.app?.exportTo;
    if (exportTo == null) {
      return null;
    }

    final exportToDir = Directory(exportTo);
    final exportedVersion = await _readVersionInfo(exportToDir);

    final appDir = Directory('web/app');
    final currentVersion = await _readVersionInfo(appDir);

    if (exportedVersion == currentVersion) {
      return currentVersion;
    }

    final allDeleted = await exportToDir
        .list(followLinks: false)
        .asyncMap((e) => e.delete(recursive: true))
        .fold(true, (previous, element) => previous && !element.existsSync());

    if (!allDeleted) {
      // TODO warn
    }

    await for (final entity in appDir.list(recursive: true)) {
      switch (entity) {
        case Directory(path: final path):
          await Directory.fromUri(exportToDir.uri.resolve(path)).create();
        case final File file:
          await file.copy(exportToDir.uri.resolve(file.path).toFilePath());
        case final Link _:
          // TODO handle
          break;
        default:
          // TODO handle
          break;
      }
    }

    return null;
  }

  Future<String?> _readVersionInfo(Directory directory) async {
    final versionFile = File.fromUri(directory.uri.resolve('version.json'));

    if (versionFile.existsSync()) {
      final versionInfo = await versionFile
          .openRead()
          .transform(utf8.decoder)
          .transform(json.decoder)
          .cast<Map<String, dynamic>>()
          .map(_AppVersionInfo.fromJson)
          .single;
      return versionInfo.version;
    }

    return null;
  }
}
