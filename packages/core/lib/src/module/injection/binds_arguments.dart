class BindsArguments {
  static final instance = BindsArguments._internal();

  BindsArguments._internal();

  final _arguments = <String, dynamic>{};

  T get<T>(String key) {
    return _arguments[key] as T;
  }

  void put<T>({required String key, required T argument}) {
    _arguments[key] = argument;
  }

  void remove(String key) {
    _arguments.remove(key);
  }
}

