import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final Widget? icon;

  const EmptyView({super.key, this.message = 'No items found.', this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? const Icon(Icons.inbox_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
