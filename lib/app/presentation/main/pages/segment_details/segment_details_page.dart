import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SegmentDetailsPage extends StatelessWidget {
  const SegmentDetailsPage({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: DSPageLayoutContainer(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DSSpacing.lg),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F7F7),
            borderRadius: DSRadius.md,
          ),
          child: Text(description, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
