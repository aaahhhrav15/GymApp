import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/result_model.dart';
import '../providers/result_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionFocus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _descriptionController = TextEditingController();
    _descriptionFocus = FocusNode();

    // Fetch results when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultProvider>().fetchResults();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: screenWidth * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.results,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.04,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.04,
          ),
          tabs: [
            Tab(
              icon: Icon(Icons.analytics, size: screenWidth * 0.05),
              text: AppLocalizations.of(context)!.myResults,
            ),
            Tab(
              icon: Icon(Icons.add_photo_alternate, size: screenWidth * 0.05),
              text: AppLocalizations.of(context)!.uploadNew,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResultsTab(),
          _buildUploadTab(),
        ],
      ),
    );
  }

  // Build Results Tab (My Results)
  Widget _buildResultsTab() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ResultProvider>(
      builder: (context, resultProvider, child) {
        if (resultProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (resultProvider.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics,
                  size: screenWidth * 0.2,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  AppLocalizations.of(context)!.noResultsYet,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  AppLocalizations.of(context)!.uploadFirstProgressPhoto,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: resultProvider.results.length,
          itemBuilder: (context, index) {
            final result = resultProvider.results[index];
            return _buildResultCard(result);
          },
        );
      },
    );
  }

  // Build Upload Tab
  Widget _buildUploadTab() {
    return Consumer<ResultProvider>(
      builder: (context, resultProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Images Section
              if (resultProvider.selectedImages.isNotEmpty) ...[
                Text(
                  'Selected Images',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: resultProvider.selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = resultProvider.selectedImages[index];
                      return Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3)),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => resultProvider.removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                    size: 16,
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
                const SizedBox(height: 24),
              ],

              // Image Selection Buttons
              Text(
                AppLocalizations.of(context)!.addImages,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.camera_alt,
                      label: AppLocalizations.of(context)!.camera,
                      onTap: () => resultProvider.pickImageFromCamera(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: AppLocalizations.of(context)!.gallery,
                      onTap: () => resultProvider.pickImageFromGallery(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description Field
              Text(
                AppLocalizations.of(context)!.description,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                maxLines: 4,
                maxLength: 200,
                onChanged: resultProvider.updateDescription,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.describeYourProgress,
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Weight Field
              Text(
                AppLocalizations.of(context)!.currentWeight,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monitor_weight,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: resultProvider.weight,
                        min: 30.0,
                        max: 200.0,
                        divisions: 340,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        label: '${resultProvider.weight.toStringAsFixed(1)} kg',
                        onChanged: resultProvider.updateWeight,
                      ),
                    ),
                    Text(
                      '${resultProvider.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      resultProvider.canUpload && !resultProvider.isUploading
                          ? () => _handleUpload(resultProvider)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: resultProvider.isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.uploading,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          AppLocalizations.of(context)!.uploadResult,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build Image Source Button
  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Result Card
  Widget _buildResultCard(ResultModel result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                _buildImageWidget(
                  result.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(result.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.delete),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.monitor_weight,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${result.weight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(result.uploadDate),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Image Widget - Updated to handle both URLs and base64
  Widget _buildImageWidget(String imageData,
      {double? width, double? height, BoxFit? fit}) {
    if (imageData.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(
          Icons.image,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    try {
      // Check if it's a URL (starts with http/https)
      if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
        debugPrint('Loading image from URL: $imageData');
        return Image.network(
          imageData,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading image from URL: $error');
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 30),
                  Text('Failed to load image', style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        );
      }

      // Check if it's a base64 data URL
      if (imageData.startsWith('data:image/')) {
        // Extract base64 part after 'data:image/[type];base64,'
        final base64String = imageData.split('base64,').last;
        debugPrint(
            'Processing data URL image, base64 length: ${base64String.length}');
        final imageBytes = base64Decode(base64String);

        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error displaying data URL image: $error');
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        );
      } else {
        // Try direct base64 decode
        debugPrint(
            'Processing direct base64 image, length: ${imageData.length}');
        final imageBytes = base64Decode(imageData);
        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error displaying direct base64 image: $error');
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      debugPrint(
          'Image data starts with: ${imageData.substring(0, imageData.length > 50 ? 50 : imageData.length)}');
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(
          Icons.broken_image,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
  }

  // Handle Upload
  Future<void> _handleUpload(ResultProvider resultProvider) async {
    _descriptionController.text = resultProvider.description;

    final result = await resultProvider.uploadResult();

    if (result['success']) {
      _descriptionController.clear();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(result['message']),
      //     backgroundColor: Theme.of(context).colorScheme.secondary,
      //   ),
      // );
      // Switch to Results tab
      _tabController.animateTo(0);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(result['error']),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
    }
  }

  // Show Delete Dialog
  void _showDeleteDialog(String resultId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Result'),
        content: const Text('Are you sure you want to delete this result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await context.read<ResultProvider>().deleteResult(resultId);
              if (success) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(AppLocalizations.of(context)!
                //         .resultDeletedSuccessfully),
                //     backgroundColor: Theme.of(context).colorScheme.secondary,
                //   ),
                // );
              } else {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(
                //         AppLocalizations.of(context)!.failedToDeleteResult),
                //     backgroundColor: Theme.of(context).colorScheme.error,
                //   ),
                // );
              }
            },
            child: Text(AppLocalizations.of(context)!.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  // Format Date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
