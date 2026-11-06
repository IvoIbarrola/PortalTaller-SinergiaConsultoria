import 'package:flutter/material.dart';

import '../models/workshop.dart';

class WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final bool selected;
  final VoidCallback? onTap;

  const WorkshopCard({
    super.key,
    required this.workshop,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.handyman_outlined),
        ),
        title: Text(workshop.name),
        subtitle: Text('${workshop.city} • ${workshop.phone}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            Text(workshop.rating.toStringAsFixed(1)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
