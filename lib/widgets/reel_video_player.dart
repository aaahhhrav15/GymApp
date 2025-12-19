import 'package:flutter/material.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isActive;

  const ReelVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isActive,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  bool _isPlaying = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    // Auto-play when active
    if (widget.isActive) {
      _isPlaying = true;
    }
  }

  @override
  void didUpdateWidget(ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle play/pause based on active state
    if (widget.isActive != oldWidget.isActive) {
      setState(() {
        _isPlaying = widget.isActive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final playIconSize = screenWidth * 0.125;
    final controlsPadding = screenWidth * 0.04;
    final overlayPadding = screenWidth * 0.04;
    final overlayTop = screenHeight * 0.06;
    final overlayBorderRadius = screenWidth * 0.02;
    final infoFontSize = screenWidth * 0.03;
    final statusFontSize = screenWidth * 0.03;
    final placeholderIconSize = screenWidth * 0.2;
    final placeholderSpacing = screenHeight * 0.02;
    final titleFontSize = screenWidth * 0.04;
    final subtitleFontSize = screenWidth * 0.03;
    final strokeWidth = screenWidth * 0.005;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = !_isPlaying;
          _showControls = true;
        });

        // Hide controls after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showControls = false;
            });
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            // Video placeholder with thumbnail
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
              ),
              child: widget.thumbnailUrl.isNotEmpty
                  ? Image.network(
                      widget.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder(screenWidth, screenHeight);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder(screenWidth, screenHeight);
                      },
                    )
                  : _buildPlaceholder(screenWidth, screenHeight),
            ),

            // Play/Pause overlay
            if (_showControls || !_isPlaying)
              Center(
                child: AnimatedOpacity(
                  opacity: _showControls || !_isPlaying ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(controlsPadding),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: playIconSize,
                    ),
                  ),
                ),
              ),

            // Loading indicator when video is loading
            if (widget.isActive && _isPlaying)
              Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: strokeWidth,
                ),
              ),

            // Video info overlay (for debugging)
            if (_showControls)
              Positioned(
                top: overlayTop,
                left: overlayPadding,
                right: overlayPadding,
                child: Container(
                  padding: EdgeInsets.all(overlayPadding * 0.75),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(overlayBorderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Video URL: ${widget.videoUrl}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: infoFontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Status: ${_isPlaying ? "Playing" : "Paused"}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: statusFontSize,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Active: ${widget.isActive}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: statusFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double screenWidth, double screenHeight) {
    final placeholderIconSize = screenWidth * 0.2;
    final placeholderSpacing = screenHeight * 0.02;
    final titleFontSize = screenWidth * 0.04;
    final subtitleFontSize = screenWidth * 0.03;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: Colors.white54,
            size: placeholderIconSize,
          ),
          SizedBox(height: placeholderSpacing),
          Text(
            'Video Preview',
            style: TextStyle(
              color: Colors.white54,
              fontSize: titleFontSize,
            ),
          ),
          SizedBox(height: placeholderSpacing * 0.5),
          Text(
            'Tap to play',
            style: TextStyle(
              color: Colors.white38,
              fontSize: subtitleFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: For production, replace this with a proper video player like:
// 
// import 'package:video_player/video_player.dart';
// 
// class ReelVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//   final String thumbnailUrl;
//   final bool isActive;
// 
//   const ReelVideoPlayer({
//     Key? key,
//     required this.videoUrl,
//     required this.thumbnailUrl,
//     required this.isActive,
//   }) : super(key: key);
// 
//   @override
//   State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
// }
// 
// class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _showControls = false;
// 
//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }
// 
//   Future<void> _initializePlayer() async {
//     _controller = VideoPlayerController.network(widget.videoUrl);
//     
//     try {
//       await _controller.initialize();
//       setState(() {
//         _isInitialized = true;
//       });
//       
//       _controller.setLooping(true);
//       
//       if (widget.isActive) {
//         _controller.play();
//       }
//     } catch (e) {
//       debugPrint('Error initializing video: $e');
//     }
//   }
// 
//   @override
//   void didUpdateWidget(ReelVideoPlayer oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     
//     if (widget.isActive != oldWidget.isActive) {
//       if (widget.isActive) {
//         _controller.play();
//       } else {
//         _controller.pause();
//       }
//     }
//   }
// 
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// 
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (_controller.value.isPlaying) {
//             _controller.pause();
//           } else {
//             _controller.play();
//           }
//           _showControls = true;
//         });
//         
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) {
//             setState(() {
//               _showControls = false;
//             });
//           }
//         });
//       },
//       child: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.black,
//         child: _isInitialized
//             ? Stack(
//                 children: [
//                   Center(
//                     child: AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: VideoPlayer(_controller),
//                     ),
//                   ),
//                   if (_showControls || !_controller.value.isPlaying)
//                     Center(
//                       child: AnimatedOpacity(
//                         opacity: _showControls || !_controller.value.isPlaying ? 1.0 : 0.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: const BoxDecoration(
//                             color: Colors.black54,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                             color: Colors.white,
//                             size: 50,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               )
//             : _buildThumbnail(),
//       ),
//     );
//   }
// 
//   Widget _buildThumbnail() {
//     return widget.thumbnailUrl.isNotEmpty
//         ? Image.network(
//             widget.thumbnailUrl,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             errorBuilder: (context, error, stackTrace) {
//               return _buildPlaceholder();
//             },
//           )
//         : _buildPlaceholder();
//   }
// 
//   Widget _buildPlaceholder() {
//     return Container(
//       color: Colors.grey[900],
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Loading video...',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
