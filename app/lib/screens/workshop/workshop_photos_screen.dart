import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WorkshopPhotosScreen extends StatefulWidget {
  final String caseId;
  final String claimNumber;

  const WorkshopPhotosScreen({
    super.key,
    required this.caseId,
    required this.claimNumber,
  });

  @override
  State<WorkshopPhotosScreen> createState() =>
      _WorkshopPhotosScreenState();
}

class _WorkshopPhotosScreenState extends State<WorkshopPhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];

  bool _isTakingPhoto = false;

  Future<void> _takePhoto() async {
    if (_isTakingPhoto) return;

    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (photo != null) {
        setState(() {
          _photos.add(photo);
        });
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo acceder a la cámara del dispositivo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _confirmPhotos() {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tomá al menos una fotografía.'),
        ),
      );
      return;
    }

    Navigator.pop(context, _photos);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro fotográfico'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.claimNumber,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fotografías del vehículo correspondientes a este siniestro.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _isTakingPhoto ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        _isTakingPhoto
                            ? 'Abriendo cámara...'
                            : 'Tomar fotografía',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fotografías tomadas: ${_photos.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _photos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Todavía no hay fotografías',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tomá fotos para documentar el estado '
                              'del vehículo y sus daños.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(_photos[index].path),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: IconButton.filled(
                                  onPressed: () => _removePhoto(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                  ),
                                  tooltip: 'Eliminar fotografía',
                                ),
                              ),
                              Positioned(
                                left: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Foto ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _photos.isEmpty ? null : _confirmPhotos,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Confirmar fotografías'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}