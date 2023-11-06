import 'package:png_helper/png_helper.dart';

/// Compress trace
class Trace {
  static int _beginTime = 0;
  static int _endTime = 0;
  static int _originSize = 0;
  static int _compressedSize = 0;
  static int _totalCount = 0;
  static int _compressCount = 0;
  static int _skipCount = 0;
  static int _giveUpCount = 0;

  static void begin() {
    _beginTime = DateTime.now().millisecondsSinceEpoch;
  }

  static void end() {
    _endTime = DateTime.now().millisecondsSinceEpoch;
  }

  static void recordSkip() {
    _totalCount++;
    _skipCount++;
  }

  static void recordGiveUp() {
    _totalCount++;
    _giveUpCount++;
  }

  static void recordCompress(int originSize, int compressedSize) {
    _totalCount++;
    _compressCount++;
    _originSize += originSize;
    _compressedSize += compressedSize;
  }

  static void summary() {
    var costTime = _endTime - _beginTime;
    var totalCompress = _originSize - _compressedSize;
    var percent = _originSize > 0 ? totalCompress / _originSize : 0;
    var summary = '''
====== PngHelper compress summary ======
  totalCount: $_totalCount
  compressCount: $_compressCount
  skipCount: ${_skipCount + _giveUpCount}
  costTime: ${_numFixed(costTime/1000)} s
  originSize: ${_numFixed(_originSize / 1000)} KB
  compressedSize: ${_numFixed(_compressedSize / 1000)} KB
  totalCompress: ${_numFixed(totalCompress / 1000)} KB
  percent ↓ : ${_numFixed(percent * 100)}%''';
    log(summary);
  }

  static String _numFixed(double num) {
    return num.toStringAsFixed(2);
  }
}