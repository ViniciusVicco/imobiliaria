import 'package:flutter/widgets.dart';

class WeightedField extends StatelessWidget {
  const WeightedField({
    super.key,
    required this.flex,
    required this.builder,
  });

  final int flex;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
