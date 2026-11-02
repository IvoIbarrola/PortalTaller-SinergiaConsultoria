import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../state/app_state.dart';

class WorkshopPhotosScreen extends StatefulWidget {
  final String caseId;
  final String claimNumber;

  const WorkshopPhotosScreen({
    super.key,
    required this.caseId,
    required this.claimNumber,
  });

  @override
  State<WorkshopPhotosScreen> createState() => _WorkshopPhotosScreenState();
}

class _WorkshopPhotosScreenState extends State<WorkshopPhotosScreen> {
  final AppState appState = AppState();
  final ImagePicker _picker = ImagePicker();

  bool _takingPhoto = false;

  bool get _canManagePhotos {
    return appState.currentUser?.role == UserRole.workshop;
  }

  Future<void> _takePhoto() async {
    if (!_canManagePhotos || _takingPhoto) return;

    setState(() => _takingPhoto = true);

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (photo != null) {
        await appState.addPhotoToCase(widget.caseId, photo.path);
        if (!mounted) return;

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotografía agregada al registro del siniestro.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la fotografía: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _takingPhoto = false);
      }
    }
  }

  Future<void> _removePhoto(String photoPath) async {
    if (!_canManagePhotos) return;

    try {
      await appState.removePhotoFromCase(widget.caseId, photoPath);
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la fotografía: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = appState.photosForCase(widget.caseId);

    return Scaffold(
      appBar: AppBar(title: const Text('Registro fotográfico')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siniestro: ${widget.claimNumber}',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  '${photos.length} fotografías registradas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_canManagePhotos) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _takingPhoto ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        _takingPhoto
                            ? 'Abriendo cámara...'
                            : 'Tomar fotografía',
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Modo de consulta: no podés agregar ni eliminar fotos.',
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: photos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 56,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay fotografías registradas.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _canManagePhotos
                                ? 'Las imágenes del caso aparecerán acá.'
                                : 'Todavía no se cargaron imágenes para este caso.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.sizeOf(context).width >= 700
                          ? 3
                          : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final path = photos[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.68),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Foto ${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            if (_canManagePhotos)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton.filledTonal(
                                  tooltip: 'Eliminar fotografía',
                                  onPressed: () => _removePhoto(path),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
