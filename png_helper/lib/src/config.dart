import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

const kPngHelperConfigFileName = 'png_helper.yaml';
const kPngHelperConfig = 'png_helper';
const kPngHelperConfigQuality = 'quality';
const kPngHelperConfigResPath = 'path';
const kPngHelperConfigIgnore = 'ignore';

/// PngHelper configuration
///
/// Recommended configuration: add png_helper.yaml file in the directory where
/// `flutter pub global run png_helper` is executed, and add the corresponding
/// configuration in it. Example:
/// ```yaml
/// png_helper:
///   # Compress quality
///   # 0 default/auto
///   # 1-10 customize
///   quality: 0
///
///   # Image path to compress
///   # Relative path to project root(actually this configuration file).
///   # Directory must end with '/'.
///   # Support any path outside the project root, for example:
///   # ../my_android_project/app/src/main/res/drawable/
///   # ../my_ios_project/Runner/Assets.xcassets/
///   path:
///     - asset/image/abc.png
///     - asset/image/
///     - path_relative_to_this_yaml_file/
///
///   # Image path to ignore
///   # Relative path to project root(actually this configuration file).
///   # Directory must end with '/'.
///   ignore:
///     - '.9.png'
///     - path_relative_to_this_yaml_file/
///```
class PngHelperConfig {

  /// Compress quality
  /// 0 default/auto
  /// 1-10 customize
  final int quality;

  /// Image path to compress
  /// Relative path to project root(actually this configuration file).
  /// Directory must end with '/'.
  final List<String> resPaths;

  /// Image path to ignore
  /// Relative path to project root(actually this configuration file).
  /// Directory must end with '/'.
  final List<String> ignore;

  PngHelperConfig({
    int? quality,
    required this.resPaths,
    List<String>? ignore,
  })  : quality = quality ?? 0,
        ignore = ignore ?? [];

  factory PngHelperConfig.fromYaml(String yamlStr) {
    var yaml = loadYaml(yamlStr) as YamlMap;
    var pngHelper = yaml[kPngHelperConfig];
    assert(pngHelper != null);
    if (pngHelper == null) {
      return PngHelperConfig(
        resPaths: [],
      );
    }
    var quality = pngHelper[kPngHelperConfigQuality];
    if(quality != null && (quality is! int || quality < 0 || quality > 10)) {
      throw Exception('"quality" should be null or in [0-10], checkout "png_helper.yaml" in demo if in confuse.');
    }

    var resPaths = pngHelper[kPngHelperConfigResPath];
    if (resPaths is! YamlList || resPaths.isEmpty) {
      throw Exception('"$kPngHelperConfigResPath" is required as a list, checkout "png_helper.yaml" in demo if in confuse.');
    }
    resPaths = resPaths.cast<String>();

    var ignore = pngHelper[kPngHelperConfigIgnore];
    if (ignore != null && ignore is! YamlList) {
      throw Exception('"$kPngHelperConfigIgnore" should be a list, checkout "png_helper.yaml" in demo if in confuse.');
    }
    var ignoreList = (ignore as YamlList?)?.cast<String>();
    if (Platform.isWindows) {
      ignoreList = ignoreList?.map((e) => e.replaceAll('/', '\\')).toList();
    }

    return PngHelperConfig(
      quality: quality,
      resPaths: resPaths,
      ignore: ignoreList,
    );
  }


  static PngHelperConfig readConfig(String directory) {
    var configFile = File(getConfigFilePath(directory));
    if (!configFile.existsSync()) {
      throw Exception('png_helper.yaml not exist in $directory');
    }
    var configYaml = configFile.readAsStringSync();
    var config = PngHelperConfig.fromYaml(configYaml);
    return config;
  }

  static String getConfigFilePath(String directory) {
    return directory + separator + kPngHelperConfigFileName;
  }
}