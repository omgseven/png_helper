import 'dart:io';

import 'package:path/path.dart';
import 'package:png_helper/png_helper.dart';

/// [CompressTaskFilter] filter compress tasks by [PngHelperConfig]
class CompressTaskFilter {
  static const String _kYamlPathSeparator = '/';

  CompressTaskFilter(this.config);

  final PngHelperConfig config;

  final List<CompressTask> tasks = [];

  /// Filter all files that meet the conditions according to [config.resPaths]
  /// and [config.ignore], and result as [CompressTask] list.
  List<CompressTask> filter() {
    tasks.clear();
    _filter();
    return tasks;
  }

  void _filter() {
    var projRoot = Host.workDir;
    for (var resPath in config.resPaths) {
      var isDirectory = resPath.endsWith(_kYamlPathSeparator);
      var resFullPath = Platform.isWindows
          ? join(projRoot, joinAll(resPath.split(_kYamlPathSeparator)))
          : join(projRoot, resPath);

      if (isDirectory) {
        _filterByPath(resFullPath);
      } else {
        _filterByFile(resFullPath);
      }
    }
  }

  void _filterByPath(String path) {
    var directory = Directory.fromUri(Uri.directory(path, windows: Platform.isWindows));
    if (!directory.existsSync()) {
      warning('png path not exist: $path');
      return;
    }
    var fileList = directory.listSync(recursive: true);
    for (var file in fileList) {
      _filterByFile(file.path);
    }
  }

  void _filterByFile(String path) {
    if (!_canHandle(path)) {
      return;
    }
    if (_isIgnore(path)) {
      return;
    }
    var file = File(path);
    if (!file.existsSync()) {
      warning('png path not exist: $path');
      return;
    }
    if (file.statSync().type != FileSystemEntityType.file) {
      return;
    }
    var dest = _getDestPath(path);
    tasks.add(CompressTask(src: path, dest: dest));
  }

  bool _isIgnore(String path) {
    return config.ignore.any((ignore) => path.contains(ignore));
  }

  /// Get the corresponding cache target path
  String _getDestPath(String path) {
    return '${Host.pngTempDir}$separator${basenameWithoutExtension(path)}_${path.hashCode}${extension(path)}';
  }

  bool _canHandle(String file) {
    return file.endsWith('.png');
  }
}

/// The compress task contains the source file path and the cache file path
class CompressTask {
  /// source file to compress
  final String src;

  /// cache file path
  final String dest;
  CompressTask({required this.src, required this.dest});
}