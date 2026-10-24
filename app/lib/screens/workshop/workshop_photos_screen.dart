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
  State<WorkshopPhotosScreen> createState() =>
      _WorkshopPhotosScreenState();
}

class _WorkshopPhotosScreenState
    extends State<WorkshopPhotosScreen> {
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
        appState.addPhotoToCase(widget.caseId, photo.path);

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
        const SnackBar(
          content: Text(
            'No se pudo abrir la cámara. Verificá los permisos.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _takingPhoto = false);
      }
    }
  }

  void _removePhoto(String photoPath) {
    if (!_canManagePhotos) return;

    appState.removePhotoFromCase(widget.caseId, photoPath);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final photos = appState.photosForCase(widget.caseId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro fotográfico'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siniestro: ${widget.claimNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text('Fotografías registradas: ${photos.length}'),
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
          const Divider(height: 1),
          Expanded(
            child: photos.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 56,
                          ),
                          SizedBox(height: 12),
                          Text('No hay fotografías registradas.'),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
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
                              errorBuilder: (_, __, ___) {
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
                                padding: const EdgeInsets.all(6),
                                color: Colors.black54,
                                child: Text(
                                  'Foto ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            if (_canManagePhotos)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton.filled(
                                  tooltip: 'Eliminar fotografía',
                                  onPressed: () => _removePhoto(path),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                  ),
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