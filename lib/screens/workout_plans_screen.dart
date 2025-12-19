import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/models/workout_plan.dart';
import 'package:gym_app_2/providers/workout_plans_provider.dart';
import 'package:gym_app_2/providers/notifications_provider.dart';
import 'package:gym_app_2/screens/workout_detail_screen.dart';
import 'package:gym_app_2/services/connectivity_service.dart';
import '../l10n/app_localizations.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<WorkoutPlansProvider>();
        provider.fetchCurrentWorkoutPlan();
        provider.fetchAllWorkoutPlans();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final provider = context.read<WorkoutPlansProvider>();
    final currentCount = provider.workoutPlans.length;

    try {
      await provider.fetchAllWorkoutPlans(
        skip: currentCount,
        append: true,
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    final provider = context.read<WorkoutPlansProvider>();

    try {
      // Refresh workout plans and notifications in parallel
      await Future.wait([
        provider.refresh(),
        context.read<NotificationsProvider>().refreshNotifications(),
      ]);
    } catch (e) {
      debugPrint('WorkoutPlansScreen: Refresh failed - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final appBarFontSize = screenWidth * 0.055;
    final contentPadding = screenWidth * 0.04;
    final sectionSpacing = screenHeight * 0.015;
    final cardBottomSpacing = screenHeight * 0.015;
    final bottomPadding = screenHeight * 0.025;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          AppLocalizations.of(context)!.knowYourWorkoutPlans,
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.medicalReferences,
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).pushNamed('/citations'),
          ),
        ],
      ),
      body: Consumer<WorkoutPlansProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.workoutPlans.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
            );
          }

          if (provider.hasError && provider.workoutPlans.isEmpty) {
            return _buildErrorState();
          }

          if (provider.workoutPlans.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Current Plan Section (if available)
                if (provider.currentWorkoutPlan != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(contentPadding),
                      child:
                          _buildCurrentPlanCard(provider.currentWorkoutPlan!),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: contentPadding),
                      child: Divider(
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],

                // All Plans Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      contentPadding,
                      contentPadding,
                      contentPadding,
                      sectionSpacing,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.allWorkoutPlans,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // Plans List
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: contentPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.workoutPlans.length) {
                          return _isLoadingMore
                              ? Padding(
                                  padding: EdgeInsets.all(contentPadding),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: cardBottomSpacing),
                          child: _buildWorkoutPlanCard(
                              provider.workoutPlans[index]),
                        );
                      },
                      childCount: provider.workoutPlans.length +
                          (_isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomPadding),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlanCard(WorkoutPlan plan) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final cardPadding = screenWidth * 0.05;
    final borderRadius = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.06;
    final subtitleFontSize = screenWidth * 0.04;
    final statusFontSize = screenWidth * 0.03;
    final goalFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.05;
    final arrowIconSize = screenWidth * 0.05;
    final chipSpacing = screenWidth * 0.03;
    final sectionSpacing = screenHeight * 0.015;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(cardPadding * 0.4),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(borderRadius * 0.6),
                ),
                child: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: iconSize,
                ),
              ),
              SizedBox(width: chipSpacing),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.currentActivePlan,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: chipSpacing,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Text(
                  plan.status.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: statusFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          Text(
            plan.plan.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Text(
            plan.plan.goal,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              fontSize: goalFontSize,
            ),
          ),
          SizedBox(height: sectionSpacing),
          Row(
            children: [
              _buildPlanInfoChip(
                Icons.fitness_center,
                plan.plan.level,
                Theme.of(context).colorScheme.onPrimary,
              ),
              SizedBox(width: chipSpacing),
              _buildPlanInfoChip(
                Icons.schedule,
                '${plan.plan.duration} ${AppLocalizations.of(context)!.weeks}',
                Theme.of(context).colorScheme.onPrimary,
              ),
              const Spacer(),
              Material(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(borderRadius * 0.8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutDetailScreen(workoutPlan: plan),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(borderRadius * 0.8),
                  child: Container(
                    padding: EdgeInsets.all(chipSpacing),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.primary,
                      size: arrowIconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlanCard(WorkoutPlan plan) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final cardPadding = screenWidth * 0.045;
    final borderRadius = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.048;
    final subtitleFontSize = screenWidth * 0.038;
    final statusFontSize = screenWidth * 0.032;
    final dateFontSize = screenWidth * 0.032;
    final arrowIconSize = screenWidth * 0.045;
    final chipSpacing = screenWidth * 0.025;
    final sectionSpacing = screenHeight * 0.018;

    Color statusColor = _getStatusColor(plan.status, context);

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.012),
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailScreen(workoutPlan: plan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: chipSpacing * 1.2,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(borderRadius * 0.8),
                    ),
                    child: Text(
                      plan.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: statusFontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(plan.startDate),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: dateFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              Text(
                plan.plan.name,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                plan.plan.goal,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sectionSpacing),
              Row(
                children: [
                  _buildPlanInfoChip(
                    Icons.fitness_center,
                    plan.plan.level,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: chipSpacing * 1.5),
                  _buildPlanInfoChip(
                    Icons.schedule,
                    '${plan.plan.duration} ${AppLocalizations.of(context)!.weeks}',
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: arrowIconSize,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanInfoChip(IconData icon, String text, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dimensions
    final iconSize = screenWidth * 0.042;
    final fontSize = screenWidth * 0.033;
    final spacing = screenWidth * 0.015;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final containerPadding = screenWidth * 0.08;
    final iconPadding = screenWidth * 0.05;
    final iconSize = screenWidth * 0.15;
    final titleFontSize = screenWidth * 0.052;
    final bodyFontSize = screenWidth * 0.042;
    final spacing = screenHeight * 0.025;
    final sectionSpacing = screenHeight * 0.02;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(containerPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                size: iconSize,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              AppLocalizations.of(context)!.noWorkoutPlansFound,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sectionSpacing),
            Text(
              'Contact your trainer to get assigned a workout plan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            SizedBox(height: spacing * 1.2),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: Icon(Icons.refresh, size: screenWidth * 0.048),
              label: Text(
                AppLocalizations.of(context)!.refresh,
                style: TextStyle(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.018,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'active':
        return Theme.of(context).colorScheme.primary;
      case 'completed':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildErrorState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final connectivityService = ConnectivityService();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: screenWidth * 0.16,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              AppLocalizations.of(context)!.unableToLoadWorkoutPlans,
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              connectivityService.isConnected
                  ? 'We\'re having trouble loading your workout plans. Please try again.'
                  : 'No internet connection. Please check your network settings and try again.',
              style: TextStyle(
                fontSize: screenWidth * 0.042,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04),
            if (connectivityService.isConnected)
              ElevatedButton.icon(
                onPressed: () {
                  final provider = context.read<WorkoutPlansProvider>();
                  provider.fetchAllWorkoutPlans();
                },
                icon: Icon(Icons.refresh, size: screenWidth * 0.048),
                label: Text(
                  AppLocalizations.of(context)!.tryAgain,
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  elevation: 2,
                ),
              ),
            SizedBox(height: screenHeight * 0.025),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/citations');
              },
              child: Text(
                AppLocalizations.of(context)!.viewMedicalReferences,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: screenWidth * 0.038,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
