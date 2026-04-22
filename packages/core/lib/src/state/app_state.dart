import 'package:flutter/material.dart';

enum AppStateEnum { isLoading, hasSuccess, hasError, idle }

class AppState extends ValueNotifier<AppStateEnum> {
  AppState() : super(AppStateEnum.idle);

  AppState.isLoading() : super(AppStateEnum.isLoading);
  AppState.hasSuccess() : super(AppStateEnum.hasSuccess);
  AppState.hasError() : super(AppStateEnum.hasError);

  void updateState({required AppStateEnum newState}) {
    value = newState;
    notifyListeners();
  }

  bool get isLoading => value == AppStateEnum.isLoading;
  bool get isIdle => value == AppStateEnum.idle;
  bool get isSuccess => value == AppStateEnum.hasSuccess;
  bool get isError => value == AppStateEnum.hasError;
}

