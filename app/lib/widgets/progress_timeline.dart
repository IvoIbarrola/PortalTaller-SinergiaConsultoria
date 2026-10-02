import 'package:flutter/material.dart';

class ProgressTimeline extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;

  const ProgressTimeline({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final active = index <= currentIndex;
          final color = active
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300;

          return SizedBox(
            width: 110,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    steps[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 56,
                    height: 2,
                    color: color,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
