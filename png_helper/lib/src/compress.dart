import 'dart:io';

import 'package:path/path.dart';
import 'package:png_helper/src/cmd.dart';
import 'package:png_helper/src/debug/debug.dart';

import '../png_helper.dart';

/// Handle compress tasks
class CompressManager {
  /// Threshold of skip compress by length
  static const kSkipByLength = 0.05;
  
  final PngHelperConfig config;

  CompressManager(this.config) {
    _createTempDirectory();
    for (var handler in _handlers) {
      _initHandler(handler);
    }
  }

  void _createTempDirectory() {
    Directory('${Host.pngTempDir}$separator').createSync(recursive: true);
  }

  void _initHandler(CompressHandler handler) {
    handler.init(quality: config.quality);
  }

  final List<CompressHandler> _handlers = [
    PngQuantHandler(),
    PngCrushHandler(),
    PngOptipngHandler(),
  ];

  void register(CompressHandler handler) {
    _handlers.add(handler);
  }

  void handleTasks(List<CompressTask> tasks) {
    for (var task in tasks) {
      handleTask(task);
    }
  }

  void handleTask(CompressTask task) {
    var destFile = File(task.dest);
    var srcFile = File(task.src);
    var srcLength = srcFile.lengthSync();
    var destExist = destFile.existsSync();
    var destLength = destExist ? destFile.lengthSync() : 0;
    if (_skipByLength(srcLength, destLength)) {
      log('skip compressed ${task.src}');
      Trace.recordSkip();
      return;
    }
    /// copy src to temp file
    srcFile.copySync(task.dest);
    /// do compress
    for (var handler in _handlers) {
      handler.handle(destFile);
    }
    /// replace src file with compressed file
    destLength = destFile.lengthSync();
    if (!_skipByLength(srcLength, destLength)) {
      var compressRate = (1 - destLength / srcLength) * 100;
      log('success compressed ${task.src} ↓ ${compressRate.toStringAsFixed(2)}%');
      Trace.recordCompress(srcLength, destLength);
      destFile.copySync(task.src);
    } else {
      log('give up compress ${task.src}');
      Trace.recordGiveUp();
    }
  }

  bool _skipByLength(int srcLength, int destLength) {
    if (destLength == 0) {
      return false;
    }
    var diff = srcLength - destLength;
    var percent = diff / srcLength;
    return percent < kSkipByLength;
  }
}

/// [CompressHandler] do the compress job
abstract class CompressHandler {
  /// compress quality, 0 for auto, [1-10] for custom, the bigger the image quality higher
  int quality = 0;

  void init({
    int? quality,
  }) {
    if (quality != null && 0 <= quality && quality < 10) {
      this.quality = quality;
    }
  }

  bool handle(File file) {
    if (canHandle(file)) {
      var code = doHandle(file);
      if (code != 0 && runningMode != RunningMode.release) {
        /// ignore: no zero code may be just not enough compress rate or something
        /// causing give up compress, no effect on use
        warning('$name exit with code $code, file: ${file.path}');
      }
      return code != 0;
    }
    return false;
  }

  bool canHandle(File file);

  int doHandle(File file);

  String get name;
}

abstract class PngHandler extends CompressHandler {
  static const kPngExtension = '.png';

  @override
  bool canHandle(File file) {
    return extension(file.path).toLowerCase() == kPngExtension;
  }
}

class PngOptipngHandler extends PngHandler {
  @override
  String get name => 'optipng';

  @override
  int doHandle(File file) {
    var args = <String>[
      '-clobber',               // overwrite existing files
      file.path,
    ];
    var result = HostCmd.optipng.execSync(args);
    return result.exitCode;
  }
}

class PngCrushHandler extends PngHandler {
  @override
  String get name => 'pngcrush';

  @override
  int doHandle(File file) {
    var args = <String>[
      '-ow',                    // Overwrite
      '-noforce',               // default; do not write output when IDAT is larger
      file.path,
    ];
    var result = HostCmd.pngcrush.execSync(args);
    return result.exitCode;
  }
}

class PngQuantHandler extends PngHandler {
  @override
  String get name => 'pngquant';

  @override
  int doHandle(File file) {
    var args = <String>[
      '--force',                // overwrite existing output files (synonym: -f)
      '--skip-if-larger',       // only save converted files if they're smaller than original
      if (_quality > 0)
        '--quality $_quality',  // don't save below min, use fewer colors below max (0-100)
      '--speed 4',              // speed/quality trade-off. 1=slow, 4=default, 11=fast & rough
      '--strip',                // remove optional metadata (default on Mac)
      '--output ${file.path}',  // output file name pattern
      file.path,
    ];
    var result = HostCmd.pngquant.execSync(args);
    return result.exitCode;
  }

  int get _quality => quality * 10;
}