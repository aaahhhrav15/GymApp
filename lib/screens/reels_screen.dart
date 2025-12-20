// import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/reels_provider.dart';
import '../models/reel_model.dart';
import '../widgets/simple_video_player.dart';
import '../widgets/report_dialog.dart';
import '../widgets/block_user_dialog.dart';
import '../services/moderation_service.dart';
import '../services/bluetooth_permission_service.dart';
import 'package:gym_app_2/services/connectivity_service.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  PageController? _pageController;
  static int _globalLastIndex = 0;
  bool _showPlayPauseIcon = false;
  bool _isCurrentlyPlaying = true;
  bool _isInitialized = false;
  int _initialPage = 0;
  bool _isScreenActive = true; // Track if screen is active
  final Map<String, bool> _expandedCaptions = {}; // Track expanded state per reel

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Register callback to pause videos when navigating away
    BluetoothPermissionService.onNavigateAwayFromReels = _pauseAllVideos;

    // Fetch reels when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeReels();
    });
  }

  void _pauseAllVideos() {
    setState(() {
      _isScreenActive = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _isScreenActive = false;
        setState(() {});
        break;
      case AppLifecycleState.resumed:
        // Check if this screen is still the current route when app resumes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && ModalRoute.of(context)?.isCurrent == true) {
            _isScreenActive = true;
            setState(() {});
          }
        });
        break;
      default:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if this route is currently active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final route = ModalRoute.of(context);
        final isCurrentRoute = route?.isCurrent ?? false;

        // Only update if the state has actually changed
        if (_isScreenActive != isCurrentRoute) {
          setState(() {
            _isScreenActive = isCurrentRoute;
          });

          print('ReelsScreen: Route active state changed to: $isCurrentRoute');
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Clean up the callback
    if (BluetoothPermissionService.onNavigateAwayFromReels == _pauseAllVideos) {
      BluetoothPermissionService.onNavigateAwayFromReels = null;
    }

    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _initializeReels() async {
    final reelsProvider = context.read<ReelsProvider>();

    // Fetch reels first
    await reelsProvider.fetchReels();

    if (reelsProvider.reels.isNotEmpty && !_isInitialized) {
      // Get initial index (resume or random)
      final initialIndex = await reelsProvider.getInitialReelIndex();

      // Set the initial page and current index
      setState(() {
        _initialPage = initialIndex;
        _pageController = PageController(initialPage: initialIndex);
      });

      // Set the current index in provider
      reelsProvider.setCurrentIndex(initialIndex);

      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.reels,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            shadows: const [
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
        actions: [
          Consumer<ReelsProvider>(
            builder: (context, reelsProvider, child) {
              return IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () async {
                  await reelsProvider.shuffleReels();
                  // Reset to first reel after shuffle
                  if (_pageController != null &&
                      reelsProvider.reels.isNotEmpty) {
                    _pageController!.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                tooltip: AppLocalizations.of(context)!.shuffleReels,
              );
            },
          ),
        ],
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

          // Show loading if PageController is not ready
          if (_pageController == null) {
            return _buildLoadingState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await reelsProvider.refreshReels();
              // After refresh, reset initialization
              _isInitialized = false;
              await _initializeReels();
            },
            color: Colors.white,
            backgroundColor: Colors.grey[800],
            child: PageView.builder(
              controller: _pageController!,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                reelsProvider.setCurrentIndex(index);
                _globalLastIndex = index;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenWidth * 0.04;
    final spacing = screenHeight * 0.025;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: spacing),
          Text(
            AppLocalizations.of(context)!.loadingReels,
            style: TextStyle(
              color: Colors.white70,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final isOnline = ConnectivityService().isConnected;
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.06;
    final iconSize = screenWidth * 0.16;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.035;
    final spacing = screenHeight * 0.03;
    final buttonPadding = screenWidth * 0.06;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: iconSize,
              color: Colors.white54,
            ),
            SizedBox(height: spacing),
            Text(
              localizations.failedToLoadReels,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing * 0.4),
            Text(
              isOnline
                  ? errorMessage
                  : localizations.noInternetConnectionCheckNetwork,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: bodyFontSize,
              ),
            ),
            SizedBox(height: spacing),
            if (isOnline)
              ElevatedButton(
                onPressed: () {
                  context.read<ReelsProvider>().fetchReels();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonPadding,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                  ),
                ),
                child: Text(localizations.tryAgain),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final iconSize = screenWidth * 0.16;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.035;
    final spacing = screenHeight * 0.03;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: iconSize,
            color: Colors.white54,
          ),
          SizedBox(height: spacing),
          Text(
            localizations.noReelsAvailable,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing * 0.4),
          Text(
            localizations.checkBackLater,
            style: TextStyle(
              color: Colors.white70,
              fontSize: bodyFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(ReelModel reel, bool isVisible) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    debugPrint(
        'ReelsScreen: Building reel item with videoUrl: ${reel.videoUrl}');
    debugPrint('ReelsScreen: Reel s3Key: ${reel.s3Key}');
    debugPrint('ReelsScreen: Reel id: ${reel.id}');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player with tap handling
        SimpleVideoPlayer(
          videoUrl: reel.videoUrl,
          autoPlay: isVisible && _isScreenActive,
          showControls: true,
          onPlayStateChanged: (isPlaying) {
            // Update the current play state and show icon
            setState(() {
              _isCurrentlyPlaying = isPlaying;
              _showPlayPauseIcon = true;
            });

            // Hide the icon after a short delay
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _showPlayPauseIcon = false;
                });
              }
            });
          },
        ),

        // Play/Pause icon overlay (temporary feedback)
        if (_showPlayPauseIcon)
          Center(
            child: AnimatedOpacity(
              opacity: _showPlayPauseIcon ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  _isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // Three-dot menu positioned on the right side
        Positioned(
          right: screenWidth * 0.04,
          top: MediaQuery.of(context).padding.top + screenHeight * 0.12,
          child: _buildThreeDotMenu(reel),
        ),

        // Overlay with user info and caption (positioned to not block video taps)
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).viewPadding.bottom +
              kBottomNavigationBarHeight +
              10,
          child: _buildOverlay(reel),
        ),
      ],
    );
  }

  Widget _buildOverlay(ReelModel reel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final nameFontSize = screenWidth * 0.04;
    final captionFontSize = screenWidth * 0.035;
    final timeFontSize = screenWidth * 0.03;

    final isExpanded = _expandedCaptions[reel.id] ?? false;
    final needsExpansion = reel.caption.length > 100; // Approximate threshold for 3 lines

    return IgnorePointer(
      ignoring: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: verticalPadding,
            bottom: MediaQuery.of(context).padding.bottom + verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Gym info
              Row(
                children: [
                  // Gym logo/profile picture
                  _buildProfileAvatar(reel),
                  SizedBox(width: screenWidth * 0.03),

                  // Gym name
                  Expanded(
                    child: Text(
                      reel.customerName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.015),

              // Caption with expand/collapse functionality
              if (reel.caption.isNotEmpty)
                GestureDetector(
                  onTap: needsExpansion
                      ? () {
                          setState(() {
                            _expandedCaptions[reel.id] = !isExpanded;
                          });
                        }
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reel.caption,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: captionFontSize,
                          height: 1.4,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        maxLines: isExpanded ? null : 3,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if (needsExpansion && !isExpanded)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.005),
                          child: Text(
                            'more',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: captionFontSize,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (needsExpansion && isExpanded)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.005),
                          child: Text(
                            'less',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: captionFontSize,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              SizedBox(height: screenHeight * 0.01),

              // Time ago
              Text(
                _formatTimeAgo(reel.createdAt),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: timeFontSize,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreeDotMenu(ReelModel reel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    final menuItemFontSize = screenWidth * 0.035;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: Colors.white,
          size: iconSize,
        ),
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        elevation: 8,
        onSelected: (value) {
          _handleMenuSelection(value, reel);
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: Colors.white,
                  size: iconSize * 0.7,
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  AppLocalizations.of(context)!.reportInappropriate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: menuItemFontSize,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'block',
            child: Row(
              children: [
                Icon(
                  Icons.block,
                  color: Colors.red,
                  size: iconSize * 0.7,
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  AppLocalizations.of(context)!.blockUser,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: menuItemFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, ReelModel reel) {
    switch (value) {
      case 'report':
        _showReportDialog(reel);
        break;
      case 'block':
        _showBlockDialog(reel);
        break;
    }
  }

  void _showReportDialog(ReelModel reel) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentType: 'reel',
        contentId: reel.id,
        contentTitle: reel.caption.isNotEmpty
            ? reel.caption
            : localizations.reelBy(reel.customerName),
      ),
    );
  }

  void _showBlockDialog(ReelModel reel) {
    showDialog(
      context: context,
      builder: (context) => BlockUserDialog(
        userId: reel.customerId,
        userName: reel.customerName,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    // Snackbars removed - no longer showing success messages
  }

  void _moveToNextReel() {
    final reelsProvider = context.read<ReelsProvider>();
    final currentIndex = reelsProvider.currentIndex;
    final nextIndex = currentIndex + 1;

    if (nextIndex < reelsProvider.reels.length && _pageController != null) {
      _pageController!.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildProfileAvatar(ReelModel reel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.1; // Responsive avatar size

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: reel.profileImageUrl != null && reel.profileImageUrl!.isNotEmpty
            ? Image.network(
                reel.profileImageUrl!,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(reel.customerName, avatarSize);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingAvatar(avatarSize);
                },
              )
            : _buildDefaultAvatar(reel.customerName, avatarSize),
      ),
    );
  }

  Widget _buildDefaultAvatar(String gymName, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04; // Responsive font size

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.8),
            Colors.blue,
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(gymName),
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progressSize =
        screenWidth * 0.05; // Responsive progress indicator size

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Center(
        child: SizedBox(
          width: progressSize,
          height: progressSize,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final localizations = AppLocalizations.of(context)!;

    if (difference.inDays > 0) {
      return localizations.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return localizations.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return localizations.minutesAgo(difference.inMinutes);
    } else {
      return localizations.justNow;
    }
  }
}

// class _ReelsScreenState extends State<ReelsScreen>
//     with WidgetsBindingObserver, RouteAware {
//   late PageController _pageController;

//   // Static variable to persist position across screen changes (Instagram approach)
//   static int _globalLastIndex = 0;
//   static bool _hasBeenInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     WidgetsBinding.instance.addObserver(this);

//     // Fetch reels when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ReelsProvider>().fetchReels().then((_) {
//         final reelsProvider = context.read<ReelsProvider>();
//         if (reelsProvider.reels.isNotEmpty) {
//           // Instagram approach: Always restore last position if initialized before
//           if (_hasBeenInitialized &&
//               _globalLastIndex < reelsProvider.reels.length) {
//             _pageController.jumpToPage(_globalLastIndex);
//             reelsProvider.setCurrentIndex(_globalLastIndex);
//             // SimpleVideoPlayer handles its own video lifecycle
//           } else {
//             // First time initialization
//             _hasBeenInitialized = true;
//             // SimpleVideoPlayer handles its own video lifecycle
//           }
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // This is called when the screen becomes active (Instagram approach)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_hasBeenInitialized && mounted) {
//         final reelsProvider = context.read<ReelsProvider>();
//         if (reelsProvider.reels.isNotEmpty &&
//             _globalLastIndex < reelsProvider.reels.length) {
//           // Restore position when screen becomes active
//           if (_pageController.hasClients &&
//               _pageController.page?.round() != _globalLastIndex) {
//             _pageController.jumpToPage(_globalLastIndex);
//             reelsProvider.setCurrentIndex(_globalLastIndex);
//             _handleVideoPlayback(reelsProvider.reels, _globalLastIndex);
//           }
//         }
//       }
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       // Save current index globally (Instagram approach)
//       _globalLastIndex = context.read<ReelsProvider>().currentIndex;
//     }
//     // SimpleVideoPlayer handles its own app lifecycle management
//   }

//     try {
//       final controller =
//           VideoPlayerController.networkUrl(Uri.parse(playableUrl));
//       _videoControllers[videoId] = controller;

//       // Initialize controller
//       controller.initialize().then((_) {
//         if (mounted) {
//           setState(() {});
//         }
//         // Auto-play if this is the current video
//         if (_currentVideoId == videoId) {
//           controller.play();
//           controller.setLooping(true);
//         }
//       }).catchError((error) {
//         debugPrint('Error initializing video: $error');
//       });

//       return controller;
//     } catch (e) {
//       debugPrint('Error creating video controller: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Responsive dimensions
//     final appBarTitleFontSize = screenWidth * 0.055;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         title: Text(
//           'Reels',
//           style: TextStyle(
//             fontSize: appBarTitleFontSize,
//             fontWeight: FontWeight.bold,
//             shadows: [
//               Shadow(
//                 offset: Offset(0, 1),
//                 blurRadius: 3.0,
//                 color: Colors.black54,
//               ),
//             ],
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
//                 _globalLastIndex =
//                     index; // Save current index globally (Instagram approach)
//                 _handleVideoPlayback(reelsProvider.reels, index);
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
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Responsive dimensions
//     final padding = screenWidth * 0.06;
//     final iconSize = screenWidth * 0.16;
//     final titleFontSize = screenWidth * 0.05;
//     final bodyFontSize = screenWidth * 0.035;
//     final spacing = screenHeight * 0.03;
//     final buttonPadding = screenWidth * 0.06;

//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(padding),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: iconSize,
//               color: Colors.white54,
//             ),
//             SizedBox(height: spacing),
//             Text(
//               'Failed to load reels',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: titleFontSize,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: spacing * 0.4),
//             Text(
//               errorMessage,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: bodyFontSize,
//               ),
//             ),
//             SizedBox(height: spacing),
//             ElevatedButton(
//               onPressed: () {
//                 context.read<ReelsProvider>().fetchReels();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: buttonPadding,
//                   vertical: screenHeight * 0.015,
//                 ),
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
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Responsive dimensions
//     final iconSize = screenWidth * 0.16;
//     final titleFontSize = screenWidth * 0.05;
//     final bodyFontSize = screenWidth * 0.035;
//     final spacing = screenHeight * 0.03;

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.video_library_outlined,
//             size: iconSize,
//             color: Colors.white54,
//           ),
//           SizedBox(height: spacing),
//           Text(
//             'No reels available',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: titleFontSize,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: spacing * 0.4),
//           Text(
//             'Check back later for new content!',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: bodyFontSize,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReelItem(ReelModel reel, bool isVisible) {
//     final controller = _getOrCreateVideoController(reel.url, reel.id);

//     return GestureDetector(
//       onTap: () {
//         print('Tapped on reel: ${reel.id}'); // Debug print
//         if (controller != null && controller.value.isInitialized) {
//           setState(() {
//             if (controller.value.isPlaying) {
//               print('Pausing video'); // Debug print
//               controller.pause();
//             } else {
//               print('Playing video'); // Debug print
//               controller.play();
//             }
//           });
//         } else {
//           print('Controller not ready'); // Debug print
//         }
//       },
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Video Player
//           SimpleVideoPlayer(
//             videoUrl: reel.videoUrl,
//             autoPlay: isVisible,
//             showControls: true,
//           ),

//           // Play/Pause indicator overlay
//           if (controller != null && controller.value.isInitialized)
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: !controller.value.isPlaying
//                   ? Container(
//                       key: const ValueKey('play-indicator'),
//                       child: Center(
//                         child: Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: Colors.black54,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.play_arrow,
//                             size: 40,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     )
//                   : Container(key: const ValueKey('playing')),
//             ),

//           // Overlay with user info and caption
//           _buildOverlay(reel),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoPlayer(String videoUrl, String videoId, bool shouldPlay) {
//     final controller = _getOrCreateVideoController(videoUrl, videoId);

//     if (controller == null) {
//       return _buildVideoErrorPlaceholder();
//     }

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: controller.value.isInitialized
//           ? Center(
//               child: AspectRatio(
//                 aspectRatio: controller.value.aspectRatio,
//                 child: VideoPlayer(controller),
//               ),
//             )
//           : _buildVideoLoadingPlaceholder(),
//     );
//   }

//   Widget _buildVideoLoadingPlaceholder() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
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

//   Widget _buildVideoErrorPlaceholder() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.white54,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Unable to load video',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Please check your connection',
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverlay(ReelModel reel) {
//     return IgnorePointer(
//       ignoring: false,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.transparent,
//               Colors.transparent,
//               Colors.black.withOpacity(0.3),
//               Colors.black.withOpacity(0.7),
//             ],
//             stops: const [0.0, 0.5, 0.8, 1.0],
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(context).padding.bottom +
//                 100, // Extra padding for bottom nav
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Spacer(),

//               // User info
//               IgnorePointer(
//                 child: Row(
//                   children: [
//                     // Profile picture placeholder
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.grey[300],
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                       child: Icon(
//                         Icons.person,
//                         color: Colors.grey[600],
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),

//                     // User name
//                     Expanded(
//                       child: Text(
//                         reel.customerName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           shadows: [
//                             Shadow(
//                               offset: Offset(0, 1),
//                               blurRadius: 3.0,
//                               color: Colors.black54,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Caption
//               if (reel.caption.isNotEmpty)
//                 IgnorePointer(
//                   child: Text(
//                     reel.caption,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       height: 1.4,
//                       shadows: [
//                         Shadow(
//                           offset: Offset(0, 1),
//                           blurRadius: 3.0,
//                           color: Colors.black54,
//                         ),
//                       ],
//                     ),
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),

//               const SizedBox(height: 8),

//               // Time ago
//               IgnorePointer(
//                 child: Text(
//                   _formatTimeAgo(reel.createdAt),
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 12,
//                     shadows: const [
//                       Shadow(
//                         offset: Offset(0, 1),
//                         blurRadius: 3.0,
//                         color: Colors.black54,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
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
