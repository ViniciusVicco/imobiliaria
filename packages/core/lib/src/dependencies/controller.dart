import 'package:legend_core/src/dependencies/mixins/logger_mixin.dart';

abstract class Controller extends Object with CustomCoreLogger {
  ///Will be called on page InitState

  Controller() {
    super.initializeObject(toString());
  }

  void dispose() {}
}


