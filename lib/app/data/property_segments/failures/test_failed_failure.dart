import 'package:legend_core/legend_core.dart';

class TestFailedFailure extends Failure {
  @override
  String get message => "Test fail by unknown error";
}
