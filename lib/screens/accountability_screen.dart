import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../providers/accountability_provider.dart';
import '../widgets/report_dialog.dart';
import '../widgets/block_user_dialog.dart';
import '../l10n/app_localizations.dart';

class AccountabilityScreen extends StatefulWidget {
  const AccountabilityScreen({super.key});

  @override
  State<AccountabilityScreen> createState() => _AccountabilityScreenState();
}

class _AccountabilityScreenState extends State<AccountabilityScreen>
    with TickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocus = FocusNode();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to update FAB visibility
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB
    });

    // Fetch uploaded images when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountabilityProvider>().fetchUploadedImages();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Helper function to build image widget from base64 or URL
  Widget _buildImageWidget(String imageData,
      {double? width, double? height, BoxFit? fit}) {
    // Handle null or empty image data
    if (imageData.trim().isEmpty) {
      debugPrint('Warning: Empty image data provided to _buildImageWidget');
      return _buildErrorWidget(width, height);
    }

    // Check if it's a base64 data URL
    if (imageData.startsWith('data:image/')) {
      try {
        // Extract base64 part after 'data:image/[type];base64,'
        final parts = imageData.split('base64,');
        if (parts.length < 2) {
          debugPrint('Error: Invalid base64 format');
          return _buildErrorWidget(width, height);
        }

        final base64String = parts.last;
        if (base64String.isEmpty) {
          debugPrint('Error: Empty base64 string');
          return _buildErrorWidget(width, height);
        }

        final Uint8List imageBytes = base64Decode(base64String);

        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error displaying memory image: $error');
            return _buildErrorWidget(width, height);
          },
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return _buildErrorWidget(width, height);
      }
    } else if (imageData.startsWith('http')) {
      // Handle network images
      return Image.network(
        imageData,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading network image: $error');
          return _buildErrorWidget(width, height);
        },
      );
    } else {
      // Invalid image data format
      debugPrint(
          'Warning: Unknown image data format: ${imageData.length > 50 ? imageData.substring(0, 50) + '...' : imageData}');
      return _buildErrorWidget(width, height);
    }
  }

  // Helper function to build error widget
  Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 300,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 50,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.imageNotAvailable,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;
    final borderRadius = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.05;
    final spacing = screenWidth * 0.05;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius * 1.25),
              topRight: Radius.circular(borderRadius * 1.25),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.1,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        AppLocalizations.of(context)!.selectImageSource,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSourceOption(
                            icon: Icons.camera_alt,
                            label: AppLocalizations.of(context)!.camera,
                            onTap: () {
                              Navigator.pop(context);
                              context
                                  .read<AccountabilityProvider>()
                                  .pickImageFromCamera();
                            },
                          ),
                          _buildSourceOption(
                            icon: Icons.photo_library,
                            label: AppLocalizations.of(context)!.gallery,
                            onTap: () {
                              Navigator.pop(context);
                              context
                                  .read<AccountabilityProvider>()
                                  .pickImageFromGallery();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.12;
    final labelFontSize = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final padding = screenWidth * 0.05;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: screenWidth * 0.025),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final titleFontSize = screenWidth * 0.08;
    final tabFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: screenWidth * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.accountability,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: tabFontSize,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: tabFontSize,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              text: AppLocalizations.of(context)!.myProgress,
              icon: Icon(Icons.photo_library, size: screenWidth * 0.05),
            ),
            Tab(
              text: AppLocalizations.of(context)!.uploadNew,
              icon: Icon(Icons.add_photo_alternate, size: screenWidth * 0.05),
            ),
          ],
        ),
        actions: [
          Consumer<AccountabilityProvider>(
            builder: (context, provider, child) {
              // Only show upload button on the upload tab
              if (_tabController.index == 1) {
                return AnimatedOpacity(
                  opacity: provider.canUpload ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: screenWidth * 0.04,
                      top: screenWidth * 0.02,
                      bottom: screenWidth * 0.02,
                    ),
                    child: ElevatedButton(
                      onPressed: provider.canUpload
                          ? () => _uploadImages(context, provider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.upload,
                        style: TextStyle(
                          fontSize: tabFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab - My Progress (Uploaded Images)
          _buildUploadedImagesTab(),
          // Second tab - Upload New Images
          _buildUploadNewTab(),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _tabController.index == 1
            ? FloatingActionButton(
                key: const ValueKey('upload_fab'),
                heroTag: "accountability_upload_fab", // Add unique hero tag
                onPressed: () => _showImageSourceDialog(context),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.add_photo_alternate,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : null,
      ),
    );
  }

  // Tab 1: Uploaded Images (My Progress)
  Widget _buildUploadedImagesTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;

    return Consumer<AccountabilityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingUploaded) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (provider.uploadedImagesSafe.isEmpty) {
          return _buildEmptyUploadedState();
        }

        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => provider.fetchUploadedImages(),
          child: ListView.builder(
            padding: EdgeInsets.all(horizontalPadding),
            itemCount: provider.uploadedImagesSafe.length,
            itemBuilder: (context, index) {
              final image = provider.uploadedImagesSafe[index];
              return _buildUploadedImageCard(image, provider);
            },
          ),
        );
      },
    );
  }

  // Tab 2: Upload New Images
  Widget _buildUploadNewTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AccountabilityProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: provider.selectedImages.isEmpty
                  ? _buildEmptyState(screenWidth, screenHeight)
                  : _buildImagesList(provider, screenWidth),
            ),
            if (provider.selectedImages.isNotEmpty) _buildDescriptionInput(),
          ],
        );
      },
    );
  }

  Widget _buildEmptyUploadedState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.16;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.035;
    final spacing = screenHeight * 0.03;
    final horizontalPadding = screenWidth * 0.06;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: iconSize * 0.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            SizedBox(height: spacing),
            Text(
              'No progress photos yet',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: spacing * 0.4),
            Text(
              'Upload your first progress photo\nto start tracking your journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            SizedBox(height: spacing),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Upload Photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedImageCard(
      Map<String, dynamic> image, AccountabilityProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;
    final cardPadding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final descriptionFontSize = screenWidth * 0.04;
    final dateFontSize = screenWidth * 0.035;
    final tagFontSize = screenWidth * 0.03;

    // Safely extract values with null checks
    final String imageUrl = image['imageUrl']?.toString() ?? '';
    final String id = image['id']?.toString() ?? '';
    final String description = image['description']?.toString() ??
        AppLocalizations.of(context)!.noDescription;
    final String uploadDate = image['uploadDate']?.toString() ?? '';

    // Skip rendering if essential data is missing
    if (imageUrl.isEmpty || id.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
            child: Stack(
              children: [
                _buildImageWidget(
                  imageUrl,
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
                        _showDeleteConfirmation(id, provider);
                      } else if (value == 'report') {
                        _showReportDialog(id, description);
                      } else if (value == 'block') {
                        _showBlockDialog(image);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.report,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.blockUser,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.delete,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
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
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Row(
                  children: [
                    Text(
                      _formatDate(uploadDate),
                      style: TextStyle(
                        fontSize: dateFontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: screenWidth * 0.04,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            'Private',
                            style: TextStyle(
                              fontSize: tagFontSize,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  String _formatDate(String dateString) {
    try {
      // Handle null or empty date strings
      if (dateString.trim().isEmpty) {
        return 'Unknown date';
      }

      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      debugPrint('Error formatting date "$dateString": $e');
      return 'Unknown date';
    }
  }

  void _showDeleteConfirmation(
      String imageId, AccountabilityProvider provider) {
    // Validate imageId before proceeding
    if (imageId.trim().isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(AppLocalizations.of(context)!.cannotDeleteInvalidId),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(l10n.deleteImage,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Text(l10n.deleteImageConfirmation,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await provider.deleteUploadedImage(imageId);
                if (success) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text(l10n.imageDeletedSuccessfully),
                  //     backgroundColor: Theme.of(context).colorScheme.primary,
                  //   ),
                  // );
                } else {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text(l10n.failedToDeleteImage),
                  //     backgroundColor: Theme.of(context).colorScheme.error,
                  //   ),
                  // );
                }
              },
              child: Text(
                l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: screenWidth * 0.12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Text(
            AppLocalizations.of(context)!.noImagesSelected,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            AppLocalizations.of(context)!.tapButtonToAddPhotos,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              height: 1.5,
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          // Visual indicator pointing to FAB
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_downward,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.tapHereToStart,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagesList(AccountabilityProvider provider, double screenWidth) {
    final horizontalPadding = screenWidth * 0.06;
    final borderRadius = screenWidth * 0.04;
    final cardPadding = screenWidth * 0.04;
    final labelFontSize = screenWidth * 0.035;

    return ListView.builder(
      padding: EdgeInsets.all(horizontalPadding),
      itemCount: provider.selectedImages.length,
      itemBuilder: (context, index) {
        final image = provider.selectedImages[index];
        return Container(
          margin: EdgeInsets.only(bottom: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
                child: Stack(
                  children: [
                    Image.file(
                      File(image.path),
                      width: double.infinity,
                      height: screenWidth * 0.6,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => provider.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding * 0.75),
                child: Text(
                  'Image ${index + 1}',
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.06;
    final borderRadius = screenWidth * 0.04;
    final labelFontSize = screenWidth * 0.04;
    final hintFontSize = screenWidth * 0.035;

    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius * 1.25),
          topRight: Radius.circular(borderRadius * 1.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Description *',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Consumer<AccountabilityProvider>(
              builder: (context, provider, child) {
                return TextField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  onChanged: (value) {
                    provider.updateDescription(value);
                  },
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe your progress...',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                      fontSize: hintFontSize,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(horizontalPadding),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImages(
      BuildContext context, AccountabilityProvider provider) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Uploading images..."),
            ],
          ),
        );
      },
    );

    try {
      final result = await provider.uploadImages();

      // Dismiss loading dialog
      Navigator.of(context).pop();

      if (result['success']) {
        // Clear the description text field
        _descriptionController.clear();

        // Navigate to uploaded images tab to see the new upload
        _tabController.animateTo(0);

        // Show success message
        // ScaffoldMessenger.of(context).showSnackBar(

        //           SnackBar(

        //             content: Row(

        //       children: [
        //         Icon(Icons.check_circle,
        //             color: Theme.of(context).colorScheme.onPrimary),
        //         const SizedBox(width: 8),
        //         const Text('Images uploaded successfully!'),
        //       ],
        //     ),
        //     backgroundColor: Theme.of(context).colorScheme.primary,
        //     duration: const Duration(seconds: 3),
        //   ),
        // );
      } else {
        // Show error message with more details
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Row(
        //       children: [
        //         Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
        //         const SizedBox(width: 8),
        //         Expanded(
        //           child: Text(
        //               'Upload failed: ${result['error'] ?? 'Unknown error'}'),
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //     duration: const Duration(seconds: 5),
        //     action: SnackBarAction(
        //       label: 'Retry',
        //       textColor: Theme.of(context).colorScheme.onError,
        //       onPressed: () => _uploadImages(context, provider),
        //     ),
        //   ),
        // );
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      Navigator.of(context).pop();

      // Show error message for unexpected errors
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
      //         const SizedBox(width: 8),
      //         Expanded(child: Text('Unexpected error: $e')),
      //       ],
      //     ),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //     duration: const Duration(seconds: 5),
      //   ),
      // );
    }
  }

  void _showReportDialog(String contentId, String description) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentType: 'accountability',
        contentId: contentId,
        contentTitle:
            description.isNotEmpty ? description : 'Accountability Post',
      ),
    );
  }

  void _showBlockDialog(Map<String, dynamic> image) {
    final String? userId = image['userId']?.toString();
    if (userId != null) {
      showDialog(
        context: context,
        builder: (context) => BlockUserDialog(
          userId: userId,
          userName: 'User', // We don't have user name in accountability data
        ),
      );
    }
  }
}
