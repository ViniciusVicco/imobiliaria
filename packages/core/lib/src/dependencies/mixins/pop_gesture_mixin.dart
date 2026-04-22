import 'package:flutter/material.dart';

mixin PopGestureMixin<T extends StatefulWidget> on State<T> {
  void onPopGestureInProgress();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRouteInfo = ModalRoute.of(context);
    if (modalRouteInfo?.popGestureInProgress == true) {
      onPopGestureInProgress();
    }
  }
}

