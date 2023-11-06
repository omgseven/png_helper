import 'package:png_helper/png_helper.dart';
import 'package:png_helper/src/compress.dart';

void main(List<String> arguments) {
  Trace.begin();
  var workDir = Host.workDir;
  var scriptDir = Host.cmdDir;
  var configFile = PngHelperConfig.getConfigFilePath(workDir);
  log('scriptDir: $scriptDir');
  log('workDir:   $workDir');
  log('config:    $configFile');

  /// read config from yaml file
  var config = PngHelperConfig.readConfig(workDir);
  /// filter compress tasks
  var tasks = CompressTaskFilter(config).filter();
  log('tasks size: ${tasks.length}');
  /// do compress jobs
  CompressManager(config).handleTasks(tasks);

  Trace.end();
  Trace.summary();
  log('======= compress done ======');
}
