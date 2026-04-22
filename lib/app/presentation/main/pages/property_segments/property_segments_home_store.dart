import 'package:legend_core/legend_core.dart';

class PropertySegmentsHomeStore extends Store {
  final AppState state = AppState();
  String? _errorMessage;

  void setLoading() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.isLoading);
  }

  void setSuccess() {
    _errorMessage = null;
    state.updateState(newState: AppStateEnum.hasSuccess);
  }

  void setError(String message) {
    _errorMessage = message;
    state.updateState(newState: AppStateEnum.hasError);
  }

  String? consumeErrorMessage() {
    final message = _errorMessage;
    _errorMessage = null;
    return message;
  }
}
