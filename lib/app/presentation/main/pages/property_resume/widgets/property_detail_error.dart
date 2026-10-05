import 'package:flutter/material.dart';

class PropertyDetailError extends StatelessWidget {
  const PropertyDetailError({
    super.key,
    required this.message,
    required this.unavailable,
    required this.onRetry,
    required this.onStock,
  });
  final String message;
  final bool unavailable;
  final VoidCallback onRetry, onStock;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            unavailable ? Icons.home_outlined : Icons.cloud_off_outlined,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: unavailable ? onStock : onRetry,
            child: Text(
              unavailable ? 'Ver imóveis disponíveis' : 'Tentar novamente',
            ),
          ),
        ],
      ),
    ),
  );
}
