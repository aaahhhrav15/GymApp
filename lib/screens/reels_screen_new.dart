// import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import 'package:provider/provider.dart';

// import '../providers/reels_provider.dart';
// import '../models/reel_model.dart';
// import '../services/reels_service.dart';

// class ReelsScreen extends StatefulWidget {
//   const ReelsScreen({super.key});

//   @override
//   State<ReelsScreen> createState() => _ReelsScreenState();
// }

// class _ReelsScreenState extends State<ReelsScreen> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();

//     // Fetch reels when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ReelsProvider>().fetchReels();
//     });
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         title: const Text(
//           'Reels',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Consumer<ReelsProvider>(
//         builder: (context, reelsProvider, child) {
//           if (reelsProvider.isLoading && reelsProvider.reels.isEmpty) {
//             return _buildLoadingState();
//           }

//           if (reelsProvider.hasError && reelsProvider.reels.isEmpty) {
//             return _buildErrorState(reelsProvider.errorMessage);
//           }

//           if (reelsProvider.reels.isEmpty) {
//             return _buildEmptyState();
//           }

//           return RefreshIndicator(
//             onRefresh: reelsProvider.refreshReels,
//             color: Colors.white,
//             backgroundColor: Colors.grey[800],
//             child: PageView.builder(
//               controller: _pageController,
//               scrollDirection: Axis.vertical,
//               onPageChanged: (index) {
//                 reelsProvider.setCurrentIndex(index);
//               },
//               itemCount: reelsProvider.reels.length,
//               itemBuilder: (context, index) {
//                 final reel = reelsProvider.reels[index];
//                 return _buildReelItem(
//                     reel, index == reelsProvider.currentIndex);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Loading reels...',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String errorMessage) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.white54,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Failed to load reels',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               errorMessage,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 context.read<ReelsProvider>().fetchReels();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.video_library_outlined,
//             size: 64,
//             color: Colors.white54,
//           ),
//           SizedBox(height: 24),
//           Text(
//             'No reels available',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             'Check back later for new content!',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReelItem(ReelModel reel, bool isVisible) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Video Player
//         _buildVideoPlayer(reel.url, isVisible),

//         // Overlay with user info and caption
//         _buildOverlay(reel),
//       ],
//     );
//   }

//   Widget _buildVideoPlayer(String videoUrl, bool shouldPlay) {
//     // Convert Google Drive URL to embeddable format if needed
//     final embedUrl = ReelsService.convertToEmbedUrl(videoUrl);

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: WebViewWidget(
//         controller: WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onPageFinished: (String url) {
//                 // Handle page load completion if needed
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse(embedUrl)),
//       ),
//     );
//   }

//   Widget _buildOverlay(ReelModel reel) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.transparent,
//             Colors.transparent,
//             Colors.black.withOpacity(0.3),
//             Colors.black.withOpacity(0.7),
//           ],
//           stops: const [0.0, 0.5, 0.8, 1.0],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Spacer(),

//             // User info
//             Row(
//               children: [
//                 // Profile picture placeholder
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.grey[300],
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     color: Colors.grey[600],
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),

//                 // User name
//                 Expanded(
//                   child: Text(
//                     reel.customerName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // Caption
//             if (reel.caption.isNotEmpty)
//               Text(
//                 reel.caption,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   height: 1.4,
//                 ),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),

//             const SizedBox(height: 8),

//             // Time ago
//             Text(
//               _formatTimeAgo(reel.createdAt),
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatTimeAgo(DateTime createdAt) {
//     final now = DateTime.now();
//     final difference = now.difference(createdAt);

//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }
