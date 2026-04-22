import 'package:dio/dio.dart';
import 'dual_response.dart';

class CancelableRequest<E, S> {
  final Future<DualResponse<E, S>> Function(CancelToken token) future;
  final ErrorResponse<E, S> Function(Object e) _onCatch;

  CancelableRequest({
    required this.future,
    required ErrorResponse<E, S> Function(Object e) onCatch,
  }) : _onCatch = onCatch;

  late dynamic Function(int) _onCancel;
  final _token = CancelToken();

  dynamic call({
    required dynamic Function(S success) onSuccess,
    required dynamic Function(E error) onError,
    required dynamic Function(int cancelRequestId) onCancel,
  }) async {
    this._onCancel = onCancel;

    try {
      final response = await future(_token);
      return response.getResult(onSuccess: onSuccess, onError: onError);
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) return;
      return onError(_onCatch(e).error);
    }
  }

  void cancel({int cancelRequestId = -1}) {
    _token.cancel();
    _onCancel.call(cancelRequestId);
  }
}

