import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/models/workout_plan.dart';
import 'package:gym_app_2/providers/workout_plans_provider.dart';
import 'package:gym_app_2/screens/workout_day_screen.dart';
import '../l10n/app_localizations.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutDetailScreen({super.key, required this.workoutPlan});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _selectedWeek = 1;

  @override
  Widget build(BuildContext context) {
    final plan = widget.workoutPlan;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final appBarFontSize = screenWidth * 0.055;
    final contentPadding = screenWidth * 0.04;
    final sectionSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          plan.plan.name,
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh logic if needed
        },
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Overview Card
              _buildPlanOverview(plan, screenWidth, screenHeight),

              SizedBox(height: sectionSpacing),

              // Week Selection
              if (plan.plan.weeks.isNotEmpty) ...[
                _buildWeekSelector(plan.plan.weeks, screenWidth, screenHeight),

                SizedBox(height: sectionSpacing),

                // Selected Week Details
                _buildWeekDetails(
                  plan.plan.weeks.firstWhere(
                    (w) => w.weekNumber == _selectedWeek,
                    orElse: () => plan.plan.weeks.first,
                  ),
                  plan,
                  screenWidth,
                  screenHeight,
                ),
              ] else ...[
                _buildNoWeeksMessage(screenWidth, screenHeight),
              ],

              SizedBox(height: sectionSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanOverview(WorkoutPlan plan, double screenWidth, double screenHeight) {
    Color statusColor = _getStatusColor(plan.status);
    final cardPadding = screenWidth * 0.05;
    final borderRadius = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.06;
    final subtitleFontSize = screenWidth * 0.04;
    final statusFontSize = screenWidth * 0.032;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
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
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(borderRadius * 0.8),
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
              const Spacer(),
              Text(
                '${AppLocalizations.of(context)!.started}: ${_formatDate(plan.startDate)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                  fontSize: subtitleFontSize * 0.9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            plan.plan.name,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            plan.plan.goal,
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.fitness_center,
                  AppLocalizations.of(context)!.level,
                  plan.plan.level,
                  Theme.of(context).colorScheme.onPrimary,
                  screenWidth,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _buildInfoCard(
                  Icons.schedule,
                  AppLocalizations.of(context)!.duration,
                  AppLocalizations.of(context)!.weeksCount(plan.plan.duration),
                  Theme.of(context).colorScheme.onPrimary,
                  screenWidth,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _buildInfoCard(
                  Icons.calendar_today,
                  AppLocalizations.of(context)!.weeks,
                  '${plan.plan.weeks.length}',
                  Theme.of(context).colorScheme.onPrimary,
                  screenWidth,
                ),
              ),
            ],
          ),
          if (plan.notes.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(borderRadius * 0.6),
                border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                    width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.notes,
                          style: TextStyle(
                            fontSize: subtitleFontSize * 0.9,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          plan.notes,
                          style: TextStyle(
                            fontSize: subtitleFontSize * 0.85,
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String label, String value, Color color, double screenWidth) {
    final cardPadding = screenWidth * 0.03;
    final fontSize = screenWidth * 0.035;
    final iconSize = screenWidth * 0.05;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(height: screenWidth * 0.02),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize * 0.75,
              color: color.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(List<Week> weeks, double screenWidth, double screenHeight) {
    final titleFontSize = screenWidth * 0.05;
    final buttonHeight = screenHeight * 0.06;
    final buttonPadding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.05;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.selectWeek,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          SizedBox(
            height: buttonHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weeks.length,
              itemBuilder: (context, index) {
                final week = weeks[index];
                final isSelected = _selectedWeek == week.weekNumber;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeek = week.weekNumber;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: screenWidth * 0.03),
                    padding: EdgeInsets.symmetric(
                        horizontal: buttonPadding, vertical: screenHeight * 0.015),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withOpacity(0.8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.weekNumber(week.weekNumber),
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDetails(Week week, WorkoutPlan plan, double screenWidth, double screenHeight) {
    final titleFontSize = screenWidth * 0.05;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.weekDays(week.weekNumber),
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          if (week.days.isEmpty)
            _buildNoDaysMessage(screenWidth, screenHeight)
          else
            ...week.days.map((day) => _buildDayCard(day, week, plan, screenWidth, screenHeight)),
        ],
      ),
    );
  }

  Widget _buildDayCard(Day day, Week week, WorkoutPlan plan, double screenWidth, double screenHeight) {
    final cardPadding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.048;
    final subtitleFontSize = screenWidth * 0.038;
    final iconSize = screenWidth * 0.05;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDayScreen(
              workoutPlan: plan,
              weekNumber: week.weekNumber,
              dayNumber: day.dayNumber,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.015),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius * 0.6),
              ),
              child: Center(
                child: Text(
                  '${day.dayNumber}',
                  style: TextStyle(
                    fontSize: titleFontSize * 0.9,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.dayNumber(day.dayNumber),
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    day.exercises.length == 1
                        ? AppLocalizations.of(context)!
                            .exerciseCount(day.exercises.length)
                        : AppLocalizations.of(context)!
                            .exercisesCount(day.exercises.length),
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  if (day.muscleGroups.isNotEmpty) ...[
                    SizedBox(height: screenHeight * 0.005),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: iconSize * 0.7,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(
                          child: Text(
                            day.muscleGroups,
                            style: TextStyle(
                              fontSize: subtitleFontSize * 0.85,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: iconSize * 0.7,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWeeksMessage(double screenWidth, double screenHeight) {
    final padding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final iconSize = screenWidth * 0.12;
    final titleFontSize = screenWidth * 0.045;
    final bodyFontSize = screenWidth * 0.038;

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
            width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: iconSize,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            AppLocalizations.of(context)!.noWeeksAvailable,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            AppLocalizations.of(context)!.noWeeksConfigured,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: Theme.of(context)
                  .colorScheme
                  .onErrorContainer
                  .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDaysMessage(double screenWidth, double screenHeight) {
    final padding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.03;
    final iconSize = screenWidth * 0.05;
    final fontSize = screenWidth * 0.038;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: iconSize,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.noWorkoutDays,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Theme.of(context).colorScheme.primary;
      case 'completed':
        return Theme.of(context).colorScheme.secondary;
      case 'paused':
        return Theme.of(context).colorScheme.tertiary;
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
