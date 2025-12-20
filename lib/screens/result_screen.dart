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
          AppLocalizations.of(context)!.results,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: titleFontSize,
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
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: tabFontSize,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: tabFontSize,
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
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final iconSize = screenWidth * 0.16;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.035;
    final spacing = screenHeight * 0.03;

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
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: iconSize,
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    AppLocalizations.of(context)!.noResultsYet,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: spacing * 0.4),
                  Text(
                    AppLocalizations.of(context)!.uploadFirstProgressPhoto,
                    style: TextStyle(
                      fontSize: bodyFontSize,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => resultProvider.fetchResults(),
          child: ListView.builder(
            padding: EdgeInsets.all(horizontalPadding),
            itemCount: resultProvider.results.length,
            itemBuilder: (context, index) {
              final result = resultProvider.results[index];
              return _buildResultCard(result);
            },
          ),
        );
      },
    );
  }

  // Build Upload Tab
  Widget _buildUploadTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final borderRadius = screenWidth * 0.04;
    final sectionTitleFontSize = screenWidth * 0.05;
    final spacing = screenHeight * 0.03;

    return Consumer<ResultProvider>(
      builder: (context, resultProvider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Images Section
              if (resultProvider.selectedImages.isNotEmpty) ...[
                Text(
                  'Selected Images',
                  style: TextStyle(
                    fontSize: sectionTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: spacing * 0.4),
                SizedBox(
                  height: screenWidth * 0.3,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: resultProvider.selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = resultProvider.selectedImages[index];
                      return Container(
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        margin: EdgeInsets.only(right: screenWidth * 0.03),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(borderRadius * 0.9),
                              child: Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: screenWidth * 0.01,
                              right: screenWidth * 0.01,
                              child: GestureDetector(
                                onTap: () => resultProvider.removeImage(index),
                                child: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.01),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .shadow
                                            .withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                    size: screenWidth * 0.04,
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
                SizedBox(height: spacing),
              ],

              // Image Selection Buttons
              Text(
                AppLocalizations.of(context)!.addImages,
                style: TextStyle(
                  fontSize: sectionTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing * 0.4),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.camera_alt,
                      label: AppLocalizations.of(context)!.camera,
                      onTap: () => resultProvider.pickImageFromCamera(),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: AppLocalizations.of(context)!.gallery,
                      onTap: () => resultProvider.pickImageFromGallery(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing),

              // Description Field
              Text(
                AppLocalizations.of(context)!.description,
                style: TextStyle(
                  fontSize: sectionTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing * 0.4),
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
                        .withOpacity(0.4),
                    fontSize: screenWidth * 0.035,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                    ),
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
              ),

              SizedBox(height: spacing),

              // Weight Field
              Text(
                AppLocalizations.of(context)!.currentWeight,
                style: TextStyle(
                  fontSize: sectionTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing * 0.4),
              Container(
                padding: EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.monitor_weight,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.03),
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
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '${resultProvider.weight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: spacing),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed:
                      resultProvider.canUpload && !resultProvider.isUploading
                          ? () => _handleUpload(resultProvider)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  child: resultProvider.isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              AppLocalizations.of(context)!.uploading,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          AppLocalizations.of(context)!.uploadResult,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.04;
    final iconSize = screenWidth * 0.12;
    final labelFontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
            SizedBox(height: screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: labelFontSize,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.04;
    final cardPadding = screenWidth * 0.04;
    final descriptionFontSize = screenWidth * 0.04;
    final infoFontSize = screenWidth * 0.035;
    final dateFontSize = screenWidth * 0.03;

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
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: screenWidth * 0.05,
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
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.description,
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
                    Icon(
                      Icons.monitor_weight,
                      size: screenWidth * 0.04,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      '${result.weight.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                        fontSize: infoFontSize,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: screenWidth * 0.04,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      _formatDate(result.uploadDate),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: dateFontSize,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.04;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        title: Text(
          'Delete Result',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this result?',
          style: TextStyle(
            fontSize: bodyFontSize,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
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
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
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
