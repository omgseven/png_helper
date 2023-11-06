import 'dart:io';

import 'package:path/path.dart';

enum RunningMode {
  release,  // publish to pub.dev
  source,   // Debug with `flutter pub global activate --source path ./png_helper`
  debug,    // Debug in IDE with break points
}

RunningMode? _runningMode;

RunningMode get runningMode => _runningMode ??= _getRunningMode();

bool get releaseMode => runningMode == RunningMode.release;

RunningMode _getRunningMode() {
  var script = Platform.script.path;
  if (script.contains('.pub-cache')) {
    return RunningMode.release;
  } else if (script.endsWith('.dart')) {
    return RunningMode.debug;
  } else if (script.endsWith('.snapshot')) {
    return RunningMode.source;
  }
  return RunningMode.release;
}

/// Debug with `flutter pub global activate --source path ./png_helper`
class DebugSourceInstall {

  /// Get the root directory of the png_helper project
  static String getCmdRoot() {
    // example: /Users/user_name/path_to_demo/png_helper/.dart_tool/pub/bin/png_helper/png_helper.dart-2.17.6.snapshot
    var snapshot = File.fromUri(Platform.script);
    var root = snapshot.path.split('$separator.dart_tool').first;
    return root;
  }
}

/// Debug in IDE with break points
class DebugIDE {

  /// Get the root directory of the png_helper project in debug mode
  /// When debugging, the command is executed in the bin directory of the project.
  static String getCmdRoot() {
    // example： /Users/path_to_pub_cache/png_helper/bin
    var snapshot = File.fromUri(Platform.script);
    return snapshot.parent.parent.path;
  }

  /// When debugging, the command is executed in the bin directory of the project.
  /// We should set the work directory to the demo app directory.
  static String getWorkDir() {
    // example： /Users/path_to_pub_cache/png_helper
    var workDir = Directory.current;
    return '${workDir.parent.path}${separator}app';
  }
}