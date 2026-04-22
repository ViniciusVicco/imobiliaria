abstract class DualResponse<E, S> {
  dynamic getResult({
    required dynamic Function(S success) onSuccess,
    required dynamic Function(E error) onError,
  });
}

class ErrorResponse<E, S> extends DualResponse<E, S> {
  ErrorResponse(this.error);

  final E error;

  @override
  dynamic getResult({
    required dynamic Function(S success) onSuccess,
    required dynamic Function(E error) onError,
  }) {
    return onError(error);
  }
}

class SuccessResponse<E, S> extends DualResponse<E, S> {
  SuccessResponse(this.success);

  final S success;

  @override
  dynamic getResult({
    required dynamic Function(S success) onSuccess,
    required dynamic Function(E error) onError,
  }) {
    return onSuccess(success);
  }
}

