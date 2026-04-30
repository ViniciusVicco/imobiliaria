import 'package:logger/logger.dart';

mixin CustomCoreLogger {
  ///Used when initializing core objects
  void initializeObject(String objectName) {
    Logger().i("Core Initialialized $objectName");
  }
}
