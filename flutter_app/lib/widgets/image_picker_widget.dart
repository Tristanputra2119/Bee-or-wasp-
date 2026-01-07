import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/constants.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(Uint8List bytes, String filename) onImageSelected;
  final bool isLoading;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.isLoading = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  bool _isDragOver = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedFileName = image.name;
        });
        widget.onImageSelected(bytes, image.name);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedFileName = image.name;
        });
        widget.onImageSelected(bytes, image.name);
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error(context),
      ),
    );
  }

  void _clearImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface(context).withOpacity(0.8),
                  AppColors.surfaceLight(context).withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: _isDragOver
                    ? AppColors.primary(context)
                    : AppColors.textMuted(context).withOpacity(0.3),
                width: _isDragOver ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isDragOver
                      ? AppColors.primary(context).withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _selectedImageBytes != null
                  ? _buildSelectedImage()
                  : _buildUploadArea(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
        ),
        // Overlay gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Loading overlay
        if (widget.isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing...',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Clear button
        if (!widget.isLoading)
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: _clearImage,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.textPrimary(context),
                  size: 20,
                ),
              ),
            ),
          ),
        // File name
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            _selectedFileName ?? 'Image',
            style: AppTextStyles.caption(context).copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: InkWell(
        onTap: widget.isLoading ? null : _pickFromGallery,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  kIsWeb ? 'Click to select image' : 'Tap to select image',
                  style: AppTextStyles.heading3(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Supports: JPG, PNG, WEBP',
                  style: AppTextStyles.caption(context),
                ),
                const SizedBox(height: 16),
                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: _pickFromGallery,
                    ),
                    if (!kIsWeb)
                      _buildActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: _pickFromCamera,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textMuted(context).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary(context)),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.caption(context)),
            ],
          ),
        ),
      ),
    );
  }
}
