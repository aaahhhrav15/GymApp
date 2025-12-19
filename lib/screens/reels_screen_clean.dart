import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reels_provider.dart';
import '../models/reel_model.dart';
import '../widgets/simple_video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with WidgetsBindingObserver, RouteAware {
  late PageController _pageController;

  // Static variable to persist position across screen changes (Instagram approach)
  static int _globalLastIndex = 0;
  static bool _hasBeenInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);

    // Fetch reels when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelsProvider>().fetchReels().then((_) {
        final reelsProvider = context.read<ReelsProvider>();
        if (reelsProvider.reels.isNotEmpty) {
          // Instagram approach: Always restore last position if initialized before
          if (_hasBeenInitialized &&
              _globalLastIndex < reelsProvider.reels.length) {
            _pageController.jumpToPage(_globalLastIndex);
            reelsProvider.setCurrentIndex(_globalLastIndex);
          } else {
            // First time initialization
            _hasBeenInitialized = true;
            reelsProvider.setCurrentIndex(0);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Setup to restore position when returning from another screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reelsProvider = context.read<ReelsProvider>();
      if (reelsProvider.reels.isNotEmpty &&
          _globalLastIndex < reelsProvider.reels.length) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_globalLastIndex);
          reelsProvider.setCurrentIndex(_globalLastIndex);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Save current index globally (Instagram approach)
      _globalLastIndex = context.read<ReelsProvider>().currentIndex;
    }
    // SimpleVideoPlayer handles its own app lifecycle management
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final appBarTitleFontSize = screenWidth * 0.055;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          'Reels',
          style: TextStyle(
            fontSize: appBarTitleFontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ReelsProvider>(
        builder: (context, reelsProvider, child) {
          if (reelsProvider.isLoading && reelsProvider.reels.isEmpty) {
            return _buildLoadingState();
          }

          if (reelsProvider.hasError && reelsProvider.reels.isEmpty) {
            return _buildErrorState(reelsProvider.errorMessage);
          }

          if (reelsProvider.reels.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: reelsProvider.refreshReels,
            color: Colors.white,
            backgroundColor: Colors.grey[800],
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                reelsProvider.setCurrentIndex(index);
                _globalLastIndex = index; // Save current index globally
              },
              itemCount: reelsProvider.reels.length,
              itemBuilder: (context, index) {
                final reel = reelsProvider.reels[index];
                return _buildReelItem(
                    reel, index == reelsProvider.currentIndex);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Loading reels...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 20),
          const Text(
            'Failed to load reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ReelsProvider>().fetchReels();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No reels available',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Check back later for new reels!',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(ReelModel reel, bool isVisible) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          SimpleVideoPlayer(
            videoUrl: reel.videoUrl,
            autoPlay: isVisible,
            showControls: true,
          ),

          // Gradient overlay for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content overlay (caption, user info, etc.)
          Positioned(
            bottom: 80,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gym name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: reel.profileImageUrl != null && reel.profileImageUrl!.isNotEmpty
                          ? NetworkImage(reel.profileImageUrl!)
                          : null,
                      child: reel.profileImageUrl == null || reel.profileImageUrl!.isEmpty
                          ? Icon(
                              Icons.fitness_center, // Gym icon instead of person
                              color: Colors.grey[600],
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      reel.customerName, // This now shows gym name via backward compatibility
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Caption
                if (reel.caption.isNotEmpty)
                  Text(
                    reel.caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Side actions (like, comment, share - you can add these later)
          Positioned(
            bottom: 80,
            right: 16,
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  onTap: () {
                    // TODO: Implement like functionality
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  onTap: () {
                    // TODO: Implement comment functionality
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    String? label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
