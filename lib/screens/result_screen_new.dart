// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import 'package:provider/provider.dart';
// import '../models/result_model.dart';
// import '../providers/result_provider.dart';

// class ResultScreen extends StatefulWidget {
//   const ResultScreen({super.key});

//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late TextEditingController _descriptionController;
//   late FocusNode _descriptionFocus;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _descriptionController = TextEditingController();
//     _descriptionFocus = FocusNode();

//     // Fetch results when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ResultProvider>().fetchResults();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _descriptionController.dispose();
//     _descriptionFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Results',
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Theme.of(context).primaryColor,
//           labelColor: Theme.of(context).primaryColor,
//           unselectedLabelColor: Colors.grey[600],
//           labelStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//           ),
//           tabs: const [
//             Tab(
//               icon: Icon(Icons.analytics),
//               text: 'My Results',
//             ),
//             Tab(
//               icon: Icon(Icons.add_photo_alternate),
//               text: 'Upload New',
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildResultsTab(),
//           _buildUploadTab(),
//         ],
//       ),
//     );
//   }

//   // Build Results Tab (My Results)
//   Widget _buildResultsTab() {
//     return Consumer<ResultProvider>(
//       builder: (context, resultProvider, child) {
//         if (resultProvider.isLoading) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         if (resultProvider.results.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.analytics,
//                   size: 80,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No results yet',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Upload your first progress photo to get started!',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[500],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: resultProvider.results.length,
//           itemBuilder: (context, index) {
//             final result = resultProvider.results[index];
//             return _buildResultCard(result);
//           },
//         );
//       },
//     );
//   }

//   // Build Upload Tab
//   Widget _buildUploadTab() {
//     return Consumer<ResultProvider>(
//       builder: (context, resultProvider, child) {
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Selected Images Section
//               if (resultProvider.selectedImages.isNotEmpty) ...[
//                 Text(
//                   'Selected Images',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 120,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: resultProvider.selectedImages.length,
//                     itemBuilder: (context, index) {
//                       final image = resultProvider.selectedImages[index];
//                       return Container(
//                         width: 120,
//                         height: 120,
//                         margin: const EdgeInsets.only(right: 12),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                         child: Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(11),
//                               child: Image.file(
//                                 File(image.path),
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                                 height: double.infinity,
//                               ),
//                             ),
//                             Positioned(
//                               top: 4,
//                               right: 4,
//                               child: GestureDetector(
//                                 onTap: () => resultProvider.removeImage(index),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: const BoxDecoration(
//                                     color: Colors.red,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.close,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],

//               // Image Selection Buttons
//               Text(
//                 'Add Images',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildImageSourceButton(
//                       icon: Icons.camera_alt,
//                       label: 'Camera',
//                       onTap: () => resultProvider.pickImageFromCamera(),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildImageSourceButton(
//                       icon: Icons.photo_library,
//                       label: 'Gallery',
//                       onTap: () => resultProvider.pickImageFromGallery(),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Description Field
//               Text(
//                 'Description',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _descriptionController,
//                 focusNode: _descriptionFocus,
//                 maxLines: 4,
//                 maxLength: 200,
//                 onChanged: resultProvider.updateDescription,
//                 decoration: InputDecoration(
//                   hintText: 'Describe your progress...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide:
//                         BorderSide(color: Theme.of(context).primaryColor),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Weight Field
//               Text(
//                 'Current Weight',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.monitor_weight, color: Colors.grey[600]),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Slider(
//                         value: resultProvider.weight,
//                         min: 30.0,
//                         max: 200.0,
//                         divisions: 340,
//                         label: '${resultProvider.weight.toStringAsFixed(1)} kg',
//                         onChanged: resultProvider.updateWeight,
//                       ),
//                     ),
//                     Text(
//                       '${resultProvider.weight.toStringAsFixed(1)} kg',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Upload Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed:
//                       resultProvider.canUpload && !resultProvider.isUploading
//                           ? () => _handleUpload(resultProvider)
//                           : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: resultProvider.isUploading
//                       ? const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Text('Uploading...',
//                                 style: TextStyle(color: Colors.white)),
//                           ],
//                         )
//                       : const Text(
//                           'Upload Result',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Build Image Source Button
//   Widget _buildImageSourceButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 32, color: Theme.of(context).primaryColor),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build Result Card
//   Widget _buildResultCard(ResultModel result) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(16),
//               topRight: Radius.circular(16),
//             ),
//             child: Stack(
//               children: [
//                 _buildImageWidget(
//                   result.imageBase64,
//                   width: double.infinity,
//                   height: 300,
//                   fit: BoxFit.cover,
//                 ),
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: PopupMenuButton<String>(
//                     icon: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: const BoxDecoration(
//                         color: Colors.black54,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.more_vert,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     onSelected: (value) {
//                       if (value == 'delete') {
//                         _showDeleteDialog(result.id);
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       const PopupMenuItem(
//                         value: 'delete',
//                         child: Row(
//                           children: [
//                             Icon(Icons.delete, color: Colors.red),
//                             SizedBox(width: 8),
//                             Text('Delete'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   result.description,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Icon(Icons.monitor_weight,
//                         size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${result.weight.toStringAsFixed(1)} kg',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const Spacer(),
//                     Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text(
//                       _formatDate(result.uploadDate),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Build Image Widget
//   Widget _buildImageWidget(String imageBase64,
//       {double? width, double? height, BoxFit? fit}) {
//     if (imageBase64.isEmpty) {
//       return Container(
//         width: width,
//         height: height,
//         color: Colors.grey[200],
//         child: const Icon(
//           Icons.image,
//           size: 50,
//           color: Colors.grey,
//         ),
//       );
//     }

//     try {
//       return Image.memory(
//         base64Decode(imageBase64),
//         width: width,
//         height: height,
//         fit: fit ?? BoxFit.cover,
//       );
//     } catch (e) {
//       return Container(
//         width: width,
//         height: height,
//         color: Colors.grey[200],
//         child: const Icon(
//           Icons.broken_image,
//           size: 50,
//           color: Colors.grey,
//         ),
//       );
//     }
//   }

//   // Handle Upload
//   Future<void> _handleUpload(ResultProvider resultProvider) async {
//     _descriptionController.text = resultProvider.description;

//     final result = await resultProvider.uploadResult();

//     if (result['success']) {
//       _descriptionController.clear();
//       // ScaffoldMessenger.of(context).showSnackBar(
       // //         SnackBar(
       // //           content: Text(result['message']),
//           backgroundColor: Colors.green,
//         ),
//       );
//       // Switch to Results tab
//       _tabController.animateTo(0);
//     } else {
//       // ScaffoldMessenger.of(context).showSnackBar(
       // //         SnackBar(
       // //           content: Text(result['error']),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Show Delete Dialog
//   void _showDeleteDialog(String resultId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Result'),
//         content: const Text('Are you sure you want to delete this result?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               final success =
//                   await context.read<ResultProvider>().deleteResult(resultId);
//               if (success) {
//                 // ScaffoldMessenger.of(context).showSnackBar(
                 // //                   const SnackBar(
                 // //                     content: Text('Result deleted successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } else {
//                 // ScaffoldMessenger.of(context).showSnackBar(
                 // //                   const SnackBar(
                 // //                     content: Text('Failed to delete result'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   // Format Date
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
