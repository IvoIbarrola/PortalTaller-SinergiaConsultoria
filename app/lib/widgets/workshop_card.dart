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
        leading: const CircleAvatar(
          child: Icon(Icons.build),
        ),
        title: Text(workshop.name),
        subtitle: Text('${workshop.city} • ${workshop.phone}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            Text(workshop.rating.toStringAsFixed(1)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
