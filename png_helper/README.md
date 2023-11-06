Image compression tool for flutter

## Usage

### Install and activate

Install from pub
```shell
flutter pub global activate png_helper
```

Install from local(For development)
go to demo project root directory, and run:
```shell
flutter pub global activate --source path ./png_helper
```

### Config

Create a `png_helper.yaml` in your project root directory, and write your configuration in it.
```yaml
png_helper:
  # Compress quality
  # 0 default/auto
  # 1-10 customize
  quality: 0

  # Image path to compress
  # Relative path to project root(actually this configuration file).
  # Directory must end with '/'.
  # Support any path outside the project root, for example: 
  # ../my_android_project/app/src/main/res/drawable/
  # ../my_ios_project/Runner/Assets.xcassets/
  path:
    - asset/image/abc.png
    - asset/image/
    - path_relative_to_this_yaml_file/

  # Image path to ignore
  # Relative path to project root(actually this configuration file).
  # Directory must end with '/'.
  ignore:
    - '.9.png'
    - path_relative_to_this_yaml_file/
```
for more details, see [PngHelperConfig](https://github.com/omgseven/png_helper/blob/master/png_helper/lib/src/config.dart)

### Run in project

Go to your project root directory(where you create `png_helper.yaml`), and run:
```shell
flutter pub global run png_helper
```

## Thanks
In this project, powerfully tools below are used to compress images:
- [pngquant](https://pngquant.org/)
- [optipng](http://optipng.sourceforge.net/)
- [pngcrush](https://pmt.sourceforge.io/pngcrush/)
