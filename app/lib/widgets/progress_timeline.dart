import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final active = index <= currentIndex;
          final color = active
              ? AppTheme.teal
              : AppTheme.border;
          final isLast = index == steps.length - 1;

          return SizedBox(
            width: isLast ? 88 : 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? AppTheme.tealInk : AppTheme.surface,
                        border: Border.all(
                          color: active ? AppTheme.tealInk : AppTheme.border,
                          width: 2,
                        ),
                      ),
                      child: active
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: color,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppTheme.text : AppTheme.mutedText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
