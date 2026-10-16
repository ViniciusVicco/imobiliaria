import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class StockEmptyState extends StatelessWidget {
  const StockEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(DSSpacing.lg),
        child: Text(
          'Nenhum imovel encontrado. Ajuste ou limpe os filtros.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
