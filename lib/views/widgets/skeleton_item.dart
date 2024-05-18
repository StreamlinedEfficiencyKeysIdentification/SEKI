// lib/widgets/skeleton_item.dart
import 'package:flutter/material.dart';

class SkeletonItem extends StatelessWidget {
  const SkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50.0,
            height: 50.0,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 12.0,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: 150.0,
                  height: 12.0,
                  color: Colors.grey[300],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
