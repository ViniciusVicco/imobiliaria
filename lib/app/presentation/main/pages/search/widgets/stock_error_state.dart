import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class StockErrorState extends StatelessWidget {
  const StockErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: DSColors.primary, size: 40),
            const SizedBox(height: DSSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: DSSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
