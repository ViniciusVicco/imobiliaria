import 'package:flutter/material.dart';

class StockLoadingState extends StatelessWidget {
  const StockLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
