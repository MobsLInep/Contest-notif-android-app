import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final String text;
  final double size;
  const LoadingSpinner({super.key, this.text = 'Loading...', this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
} 