import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubscriptionScreen extends HookConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 64),
            SizedBox(height: 16),
            Text('Subscription Screen - Coming Soon'),
            Text('Premium response windows: 4h, 6h, 8h'),
          ],
        ),
      ),
    );
  }
}