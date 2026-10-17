import 'dart:io';

import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_save_request.dart';
import 'package:app_movil_sistema/features/productimage/domain/entities/product_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImageSelection {
  final List<ProductImage> existingImages;
  final List<ProductImageUpload> newImages;
  final String? mainImageKey;

  const ProductImageSelection({
    required this.existingImages,
    required this.newImages,
    this.mainImageKey,
  });
}

class XsProductImagePicker extends StatefulWidget {
  final List<ProductImage> existingImages;
  final int maxFileSizeBytes;
  final ValueChanged<ProductImageSelection> onChanged;

  const XsProductImagePicker({
    super.key,
    required this.existingImages,
    required this.maxFileSizeBytes,
    required this.onChanged,
  });

  @override
  State<XsProductImagePicker> createState() => _XsProductImagePickerState();
}

class _XsProductImagePickerState extends State<XsProductImagePicker> {
  final ImagePicker _imagePicker = ImagePicker();
  late List<ProductImage> _existingImages;
  final List<ProductImageUpload> _newImages = [];
  int? _mainExistingId;
  String? _mainNewImagePath;

  @override
  void initState() {
    super.initState();
    _existingImages = List.of(widget.existingImages);
    for (final image in _existingImages) {
      if (image.isMain) {
        _mainExistingId = image.id;
        break;
      }
    }
  }

  String get _maxSizeLabel =>
      '${(widget.maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';

  void _emitSelection() {
    String? mainImageKey;
    if (_mainExistingId != null) {
      mainImageKey = 'existing:$_mainExistingId';
    } else if (_mainNewImagePath != null) {
      final index = _newImages.indexWhere(
        (image) => image.path == _mainNewImagePath,
      );
      if (index >= 0) mainImageKey = 'temp:$index';
    }

    widget.onChanged(
      ProductImageSelection(
        existingImages: List.unmodifiable(_existingImages),
        newImages: List.unmodifiable(_newImages),
        mainImageKey: mainImageKey,
      ),
    );
  }

  Future<void> _showImageSourceOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Seleccionar de la galería'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final images = await _imagePicker.pickMultiImage();
    await _addImages(images);
  }

  Future<void> _pickFromCamera() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) await _addImages([image]);
  }

  Future<void> _addImages(List<XFile> files) async {
    if (files.isEmpty) return;

    final validImages = <ProductImageUpload>[];
    var rejectedCount = 0;

    for (final file in files) {
      if (await file.length() > widget.maxFileSizeBytes) {
        rejectedCount++;
        continue;
      }
      if (_newImages.any((image) => image.path == file.path)) continue;
      validImages.add(ProductImageUpload(path: file.path, fileName: file.name));
    }

    if (!mounted) return;
    setState(() {
      _newImages.addAll(validImages);
      if (_mainExistingId == null &&
          _mainNewImagePath == null &&
          _newImages.isNotEmpty) {
        _mainNewImagePath = _newImages.first.path;
      }
    });
    _emitSelection();

    if (rejectedCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            rejectedCount == 1
                ? 'Una imagen supera el máximo permitido de $_maxSizeLabel.'
                : '$rejectedCount imágenes superan el máximo permitido de $_maxSizeLabel.',
          ),
        ),
      );
    }
  }

  void _removeExisting(ProductImage image) {
    setState(() {
      _existingImages.removeWhere((current) => current.id == image.id);
      if (_mainExistingId == image.id) {
        _mainExistingId = null;
        _mainNewImagePath = _newImages.isNotEmpty
            ? _newImages.first.path
            : null;
      }
    });
    _emitSelection();
  }

  void _removeNew(ProductImageUpload image) {
    setState(() {
      _newImages.removeWhere((current) => current.path == image.path);
      if (_mainNewImagePath == image.path) {
        _mainNewImagePath = _newImages.isNotEmpty
            ? _newImages.first.path
            : null;
      }
    });
    _emitSelection();
  }

  void _selectExistingAsMain(ProductImage image) {
    setState(() {
      _mainExistingId = image.id;
      _mainNewImagePath = null;
    });
    _emitSelection();
  }

  void _selectNewAsMain(ProductImageUpload image) {
    setState(() {
      _mainExistingId = null;
      _mainNewImagePath = image.path;
    });
    _emitSelection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Imágenes del producto', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Peso máximo por imagen: $_maxSizeLabel.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._existingImages.map(
              (image) => _ImageTile(
                dismissKey: 'existing:${image.id}',
                isMain: _mainExistingId == image.id,
                onSetMain: () => _selectExistingAsMain(image),
                onRemove: () => _removeExisting(image),
                imageProvider: NetworkImage(
                  EnvConfig.resolveBackendFileUrl(image.imageUrl),
                ),
              ),
            ),
            ..._newImages.map(
              (image) => _ImageTile(
                dismissKey: 'new:${image.path}',
                isMain: _mainNewImagePath == image.path,
                onSetMain: () => _selectNewAsMain(image),
                onRemove: () => _removeNew(image),
                imageProvider: FileImage(File(image.path)),
              ),
            ),
            _AddImageTile(onTap: _showImageSourceOptions),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String dismissKey;
  final ImageProvider imageProvider;
  final bool isMain;
  final VoidCallback onSetMain;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.dismissKey,
    required this.imageProvider,
    required this.isMain,
    required this.onSetMain,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Dismissible(
        key: ValueKey(dismissKey),
        direction: DismissDirection.horizontal,
        resizeDuration: null,
        background: const _DeleteBackground(),
        secondaryBackground: const _DeleteBackground(),
        confirmDismiss: (_) => _confirmRemoval(context),
        onDismissed: (_) => onRemove(),
        child: SizedBox(
          width: 112,
          height: 112,
          child: Material(
            elevation: isMain ? 5 : 2,
            shadowColor: isMain
                ? colorScheme.primary.withValues(alpha: .35)
                : Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isMain
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isMain ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            color: colorScheme.surfaceContainerHighest,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Ink.image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  child: InkWell(
                    onTap: () => _showImagePreview(context, imageProvider),
                    child: const SizedBox.expand(),
                  ),
                ),
                if (isMain)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: colorScheme.primary.withValues(alpha: .88),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Principal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  left: 5,
                  bottom: isMain ? 28 : 5,
                  child: IconButton.filled(
                    tooltip: isMain
                        ? 'Imagen principal'
                        : 'Marcar como principal',
                    onPressed: onSetMain,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 34,
                      height: 34,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isMain
                          ? AppColors.warningDark
                          : colorScheme.primary,
                    ),
                    icon: Icon(isMain ? Icons.star : Icons.star_border),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _confirmRemoval(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Eliminar imagen'),
          content: const Text('La imagen se eliminará al guardar el producto.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.dangerDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }
}

void _showImagePreview(BuildContext context, ImageProvider imageProvider) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: Image(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              tooltip: 'Cerrar vista previa',
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              icon: const Icon(Icons.close),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Text(
              'Usa dos dedos para acercar o alejar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Agregar', textAlign: TextAlign.center),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
