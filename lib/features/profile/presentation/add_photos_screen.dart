import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_profile_provider.dart';

class AddPhotosScreen extends HookConsumerWidget {
  const AddPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final picker = ImagePicker();
    
    // Get existing photos from Firestore
    final existingPhotos = ref.watch(userPhotoUrlsProvider);
    final userProfileNotifier = ref.watch(userProfileNotifierProvider.notifier);
    
    // State for storing selected photos (mix of existing URLs and new XFiles)
    final photos = useState<List<dynamic>>(List.filled(6, null));
    final isLoading = useState(false);

    // Initialize with existing photos on first build
    useEffect(() {
      if (existingPhotos.isNotEmpty && photos.value.every((p) => p == null)) {
        final newPhotos = List<dynamic>.filled(6, null);
        for (int i = 0; i < existingPhotos.length && i < 6; i++) {
          newPhotos[i] = existingPhotos[i]; // String URLs from Firestore
        }
        photos.value = newPhotos;
      }
      return null;
    }, [existingPhotos]);

    // Calculate how many photos are uploaded
    int uploadedCount = photos.value.where((photo) => photo != null).length;
    bool canContinue = uploadedCount >= 3;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Photos',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (canContinue)
            TextButton(
              onPressed: isLoading.value ? null : () async {
                isLoading.value = true;
                
                // Filter out null values and use the new Firebase Storage upload method
                final nonNullPhotos = photos.value.where((photo) => photo != null).toList();
                
                // Save to Firestore with Firebase Storage upload
                final success = await userProfileNotifier.updatePhotosWithUpload(nonNullPhotos);
                isLoading.value = false;
                
                if (success) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Photos uploaded and saved! ($uploadedCount/6)',
                        style: GoogleFonts.lobster(fontSize: 12),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to upload photos. Please try again.',
                        style: GoogleFonts.lobster(fontSize: 12),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: isLoading.value 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Done',
                      style: GoogleFonts.lobster(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Show Your Best Self',
                style: GoogleFonts.lobster(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                'Add at least 3 photos to get started. You can add up to 6 photos to showcase your personality.',
                style: GoogleFonts.lobster(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ).animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              // Photo count indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: canContinue ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canContinue ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      canContinue ? Icons.check_circle : Icons.photo_camera,
                      color: canContinue ? Colors.green : theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$uploadedCount/6 photos ${canContinue ? '(Ready!)' : '(${3 - uploadedCount} more needed)'}',
                      style: GoogleFonts.lobster(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: canContinue ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 32),
              
              // Photo grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final photo = photos.value[index];
                    final isEmpty = photo == null;
                    final isRequired = index < 3;
                    
                    return GestureDetector(
                      onTap: () async {
                        if (isLoading.value) return;
                        
                        if (isEmpty) {
                          // Add photo
                          await _showPhotoSourceDialog(context, picker, photos, index);
                        } else {
                          // Remove or replace photo
                          await _showPhotoOptionsDialog(context, picker, photos, index);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isEmpty ? theme.colorScheme.surface : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEmpty 
                                ? (isRequired && uploadedCount < 3)
                                    ? Colors.red.withValues(alpha: 0.5)
                                    : theme.colorScheme.outline.withValues(alpha: 0.5)
                                : Colors.transparent,
                            width: isEmpty ? 2 : 0,
                          ),
                        ),
                        child: isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: (isRequired && uploadedCount < 3)
                                        ? Colors.red.withValues(alpha: 0.7)
                                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isRequired ? 'Required' : 'Optional',
                                    style: GoogleFonts.lobster(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: (isRequired && uploadedCount < 3)
                                          ? Colors.red
                                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  if (index == 0)
                                    Text(
                                      'Main Photo',
                                      style: GoogleFonts.lobster(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: photo is String 
                                        ? Image.network(
                                            photo,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Center(child: CircularProgressIndicator()),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.error),
                                              );
                                            },
                                          )
                                        : Image.file(
                                            File((photo as XFile).path),
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          await _showPhotoOptionsDialog(context, picker, photos, index);
                                        },
                                      ),
                                    ),
                                  ),
                                  if (index == 0)
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Main',
                                          style: GoogleFonts.lobster(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ).animate(delay: (index * 100).ms)
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canContinue && !isLoading.value) ? () async {
                    isLoading.value = true;
                    
                    // Save photos with Firebase Storage upload before continuing
                    final nonNullPhotos = photos.value.where((photo) => photo != null).toList();
                    final success = await userProfileNotifier.updatePhotosWithUpload(nonNullPhotos);
                    isLoading.value = false;
                    
                    if (success) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Photos uploaded! Add prompts next.',
                            style: GoogleFonts.lobster(fontSize: 12),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to upload photos.',
                            style: GoogleFonts.lobster(fontSize: 12),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: canContinue ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          canContinue ? 'Continue to Prompts' : 'Add ${3 - uploadedCount} More Photos',
                          style: GoogleFonts.lobster(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: canContinue ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ).animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  // Show dialog to choose photo source
  Future<void> _showPhotoSourceDialog(
    BuildContext context, 
    ImagePicker picker, 
    ValueNotifier<List<dynamic>> photos, 
    int index
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Photo',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(
                'Take Photo',
                style: GoogleFonts.lobster(fontSize: 14),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final photo = await picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  final newPhotos = List<dynamic>.from(photos.value);
                  newPhotos[index] = photo;
                  photos.value = newPhotos;
                } else {
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'Choose from Gallery',
                style: GoogleFonts.lobster(fontSize: 14),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final photo = await picker.pickImage(source: ImageSource.gallery);
                if (photo != null) {
                  final newPhotos = List<dynamic>.from(photos.value);
                  newPhotos[index] = photo;
                  photos.value = newPhotos;
                } else {
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog for photo options (replace/remove)
  Future<void> _showPhotoOptionsDialog(
    BuildContext context, 
    ImagePicker picker, 
    ValueNotifier<List<dynamic>> photos, 
    int index
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Photo Options',
          style: GoogleFonts.lobster(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(
                'Replace Photo',
                style: GoogleFonts.lobster(fontSize: 14),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await _showPhotoSourceDialog(context, picker, photos, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(
                'Remove Photo',
                style: GoogleFonts.lobster(fontSize: 14),
              ),
              onTap: () {
                Navigator.of(context).pop();
                final newPhotos = List<dynamic>.from(photos.value);
                newPhotos[index] = null;
                photos.value = newPhotos;
              },
            ),
          ],
        ),
      ),
    );
  }
}