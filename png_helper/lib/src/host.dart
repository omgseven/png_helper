import 'dart:io';

import 'package:path/path.dart';
import 'package:png_helper/src/pub_cache.dart';

import 'debug/debug.dart';

class Host {
  static String? _workDir;
  static String? _cmdDir;
  static String? _thirdPartyToolsRoot;
  static String? _pngTempDir;

  /// image compress tools
  static String? _optipngPath;
  static String? _pngcrushPath;
  static String? _pngquantPath;

  static String get pngTempDir => _pngTempDir ??= '$workDir$separator.dart_tool${separator}png_helper';

  /// workspace, same as directory where the command is executed
  static String get workDir => _workDir ??= _getWorkDir();

  /// command directory, same as the root directory of the current script project root
  static String get cmdDir => _cmdDir ??= _getCmdRoot();

  static String get thirdPartyToolsRoot => _thirdPartyToolsRoot ??= _getThirdPartyToolsRoot();

  static String get optipngPath => _optipngPath ??= _getPngTool('optipng');

  static String get pngcrushPath => _pngcrushPath ??= _getPngTool('pngcrush');

  static String get pngquantPath => _pngquantPath ??= _getPngTool('pngquant');

  /// Get the path of the [name] command
  /// The command is in the png_helper/third_party/png_tools/ directory.
  static String _getPngTool(String name) {
    // TODO(add linux arm64 support)
    var isArm64 = Platform.isMacOS && Platform.version.contains('macos_arm64');
    var platformCmd = join(thirdPartyToolsRoot, Platform.operatingSystem, name);
    if (isArm64) {
      var platformCmdArm64 = '$platformCmd-arm64';
      if (platformFile(platformCmdArm64).existsSync()) {
        return platformCmdArm64;
      }
    }
    return platformCmd;
  }

  static File platformFile(String path) {
    return File.fromUri(Uri.file(path, windows: Platform.isWindows));
  }

  static String _getWorkDir() {
    return releaseMode ? Directory.current.path : DebugIDE.getWorkDir();
  }

  static String _getCmdRoot() {
    switch (runningMode) {
      case RunningMode.release:
        return PubCache.pngHelperGlobalCmdPath;
      case RunningMode.source:
        return DebugSourceInstall.getCmdRoot();
      case RunningMode.debug:
        return DebugIDE.getCmdRoot();
    }
  }

  static String _getThirdPartyToolsRoot() {
    return releaseMode ? PubCache.thirdPartyToolsRoot : join(cmdDir, 'third_party', 'png_tools');
  }
}