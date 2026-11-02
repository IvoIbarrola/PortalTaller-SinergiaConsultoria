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
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final active = index <= currentIndex;
          final color = active ? colors.secondary : colors.outlineVariant;
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
                        color: active ? colors.primary : colors.surface,
                        border: Border.all(
                          color: active
                              ? colors.primary
                              : colors.outlineVariant,
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
                      Expanded(child: Container(height: 2, color: color)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? colors.onSurface : colors.onSurfaceVariant,
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
