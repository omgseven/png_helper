import 'dart:io';

import '../png_helper.dart';

/// Executable command
class Cmd {
  final String path;
  Cmd({required this.path}) {
    var permissionResult = ensurePermission();
    if (permissionResult.exitCode != 0) {
      warning('Cmd: $path ensure executable permission failed.');
    }
  }

  ProcessResult ensurePermission() {
    var args = ['+x', path];
    return Process.runSync('chmod', args);
  }

  Future<ProcessResult> exec(List<String> args) {
    return Process.run(path, args);
  }

  ProcessResult execSync(List<String> args) {
    return Process.runSync(path, args);
  }
}

/// Platform command
/// Automatically select the corresponding command according to the given
/// command name on different platforms through [Host].
class HostCmd {
  static Cmd? _optipng;
  static Cmd? _pngcrush;
  static Cmd? _pngquant;

  static Cmd get optipng => _optipng ??= Cmd(path: Host.optipngPath);
  static Cmd get pngcrush => _pngcrush ??= Cmd(path: Host.pngcrushPath);
  static Cmd get pngquant => _pngquant ??= Cmd(path: Host.pngquantPath);
}

