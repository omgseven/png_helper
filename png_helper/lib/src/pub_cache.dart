import 'dart:io';

import 'package:path/path.dart';

/// Handle pub cache path
class PubCache {
  static String? _root;
  static String? _pngHelperCmdPath;
  static String? _pngHelperVersion;
  static String? _thirdPartyToolsRoot;

  /// Root path of the pub cache
  /// example: /Users/user_name/.pub-cache
  static String get root => _root ??= _getPubCacheRoot();

  /// Path of the global installed png_helper command
  static String get pngHelperGlobalCmdPath => _pngHelperCmdPath ??= join(root, 'bin', 'png_helper');

  /// Version of the current installed png_helper
  static String get pngHelperInstalledVersion => _pngHelperVersion ??= _getPngHelperVersion();

  /// Path of the third party tools
  static String get thirdPartyToolsRoot => _thirdPartyToolsRoot ??= _getThirdPartyToolsRoot();

  static String _getThirdPartyToolsRoot() {
    /// example: /Users/user_name/.pub-cache/hosted/pub.flutter-io.cn/png_helper-1.0.0/third_party/png_tools
    return join(root, 'hosted', 'pub.flutter-io.cn', 'png_helper-$pngHelperInstalledVersion', 'third_party', 'png_tools');
  }

  /// Root path of the pub cache
  /// example: /Users/user_name/.pub-cache
  static String _getPubCacheRoot() {
    if (Platform.isWindows) {
      return Platform.environment['LOCALAPPDATA'] ?? '';
    } else {
      return '${Platform.environment['HOME']}/.pub-cache';
    }
  }

  /// Read version from 'png_helper' global install script file
  /// example:
  /// ```shell
  /// #!/usr/bin/env sh
  /// # This file was created by pub v2.17.6.
  /// # Package: png_helper
  /// # Version: 1.0.0
  /// # Executable: png_helper
  /// # Script: png_helper
  /// ```
  static String _getPngHelperVersion() {
    var cmdFile = File(pngHelperGlobalCmdPath);
    var lines = cmdFile.readAsLinesSync();
    var versionLine = lines.firstWhere((element) => element.contains('Version:'));
    var version = versionLine.split(' ').last;
    return version;
  }
}