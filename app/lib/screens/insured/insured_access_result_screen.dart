import 'package:flutter/material.dart';

class InsuredAccessResultScreen extends StatelessWidget {
  final Map<String, dynamic> caseData;

  const InsuredAccessResultScreen({super.key, required this.caseData});

  String _text(dynamic value, {String fallback = 'Sin información'}) {
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString();
  }

  String _date(dynamic value) {
    if (value == null) return 'Sin fecha estimada';
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return 'Sin fecha estimada';
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = caseData['vehicle'] is Map
        ? Map<String, dynamic>.from(caseData['vehicle'] as Map)
        : <String, dynamic>{};
    final photos = caseData['photos'] is List
        ? (caseData['photos'] as List).whereType<Map>().map((p) => Map<String, dynamic>.from(p)).toList()
        : <Map<String, dynamic>>[];
    final progress = ((caseData['progress'] as num?)?.toDouble() ?? 0).clamp(0.0, 100.0);

    return Scaffold(
      appBar: AppBar(title: Text(_text(caseData['claimNumber'], fallback: 'Mi siniestro'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Estado del siniestro', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_text(caseData['status']), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress / 100, minHeight: 6),
              const SizedBox(height: 8),
              Text('${progress.toStringAsFixed(0)}% completado'),
              const Divider(height: 24),
              Text(_text(caseData['description'])),
              const SizedBox(height: 12),
              _DetailRow(label: 'Ingreso', value: _date(caseData['entryDate'])),
              _DetailRow(label: 'Entrega estimada', value: _date(caseData['estimatedDeliveryDate'])),
              _DetailRow(label: 'Aseguradora', value: _text(caseData['insurerCompany'])),
            ]),
          )),
          const SizedBox(height: 16),
          Text('Vehículo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_text(vehicle['brand'])} ${_text(vehicle['model'], fallback: '')}'.trim(),
                style: Theme.of(context).textTheme.titleMedium),
              _DetailRow(label: 'Año', value: _text(vehicle['year'])),
              _DetailRow(label: 'Patente', value: _text(vehicle['plate'])),
              _DetailRow(label: 'Color', value: _text(vehicle['color'])),
            ]),
          )),
          const SizedBox(height: 16),
          Text('Registro fotográfico', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (photos.isEmpty)
            const Card(child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Todavía no hay fotos registradas para este siniestro.'),
            ))
          else
            ...photos.map((photo) {
              final url = _text(photo['url'], fallback: '');
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (url.isNotEmpty)
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) => progress == null
                          ? child
                          : const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                      errorBuilder: (_, __, ___) => const SizedBox(height: 120, child: Center(child: Icon(Icons.broken_image_outlined, size: 40))),
                    ),
                  if (_text(photo['caption'], fallback: '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_text(photo['caption'])),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Text(_date(photo['createdAt']), style: Theme.of(context).textTheme.bodySmall),
                  ),
                ]),
              );
            }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al acceso'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 140, child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
