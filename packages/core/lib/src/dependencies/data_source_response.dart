import 'package:legend_core/src/dependencies/response.dart';

class DataSourceResponse<T> extends Response {
  final T data;
  final bool hasSuccess;

  DataSourceResponse({required this.data, required this.hasSuccess});
}


