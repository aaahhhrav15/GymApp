import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/models/workout_plan.dart';
import 'package:gym_app_2/providers/workout_plans_provider.dart';
import '../l10n/app_localizations.dart';

class WorkoutDayScreen extends StatefulWidget {
  final WorkoutPlan workoutPlan;
  final int weekNumber;
  final int dayNumber;

  const WorkoutDayScreen({
    super.key,
    required this.workoutPlan,
    required this.weekNumber,
    required this.dayNumber,
  });

  @override
  State<WorkoutDayScreen> createState() => _WorkoutDayScreenState();
}

class _WorkoutDayScreenState extends State<WorkoutDayScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch detailed workout day data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutDayProvider>().fetchWorkoutDay(
            widget.weekNumber,
            widget.dayNumber,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarFontSize = screenWidth * 0.055;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          'Week ${widget.weekNumber} - Day ${widget.dayNumber}',
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<WorkoutDayProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
            );
          }

          if (provider.hasError) {
            return _buildErrorState(provider.error!);
          }

          // Use either API data or local data as fallback
          final workoutDay = provider.currentWorkoutDay;
          final localDay = _getLocalDayData();

          if (workoutDay == null && localDay == null) {
            return _buildNoDataState();
          }

          final exercises = workoutDay?.exercises ?? localDay?.exercises ?? [];
          final planMeta = workoutDay?.planMeta ?? _getPlanMetaFromLocal();

          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final sectionSpacing = screenHeight * 0.02;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchWorkoutDay(
                  widget.weekNumber, widget.dayNumber);
            },
            color: Theme.of(context).colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Info Header
                  _buildPlanInfoHeader(planMeta, screenWidth, screenHeight),

                  SizedBox(height: sectionSpacing),

                  // Day Overview
                  _buildDayOverview(
                      exercises.length,
                      workoutDay?.muscleGroups ?? localDay?.muscleGroups ?? '',
                      screenWidth,
                      screenHeight),

                  SizedBox(height: sectionSpacing),

                  // Exercises List
                  if (exercises.isEmpty)
                    _buildNoExercisesMessage(screenWidth, screenHeight)
                  else
                    _buildExercisesList(exercises, screenWidth, screenHeight),

                  SizedBox(height: sectionSpacing),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanInfoHeader(PlanMeta? planMeta, double screenWidth, double screenHeight) {
    final cardPadding = screenWidth * 0.05;
    final borderRadius = screenWidth * 0.05;
    final titleFontSize = screenWidth * 0.06;
    final subtitleFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.05;

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
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(borderRadius * 0.6),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: iconSize,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planMeta?.name ?? widget.workoutPlan.plan.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      planMeta?.goal ?? widget.workoutPlan.plan.goal,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.9),
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildHeaderInfo(
                  AppLocalizations.of(context)!.level,
                  planMeta?.level ?? widget.workoutPlan.plan.level,
                  screenWidth,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: _buildHeaderInfo(
                  AppLocalizations.of(context)!.week,
                  '${widget.weekNumber}',
                  screenWidth,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: _buildHeaderInfo(
                  AppLocalizations.of(context)!.day,
                  '${widget.dayNumber}',
                  screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value, double screenWidth) {
    final labelFontSize = screenWidth * 0.032;
    final valueFontSize = screenWidth * 0.04;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenWidth * 0.005),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildDayOverview(int exerciseCount, String muscleGroups, double screenWidth, double screenHeight) {
    final cardPadding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.048;
    final subtitleFontSize = screenWidth * 0.038;
    final iconSize = screenWidth * 0.05;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(borderRadius * 0.6),
            ),
            child: Icon(
              Icons.assignment,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.todaysWorkout,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  exerciseCount == 1
                      ? AppLocalizations.of(context)!
                          .exercisePlanned(exerciseCount)
                      : AppLocalizations.of(context)!
                          .exercisesPlanned(exerciseCount),
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                if (muscleGroups.isNotEmpty) ...[
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: iconSize * 0.7,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Expanded(
                        child: Text(
                          muscleGroups,
                          style: TextStyle(
                            fontSize: subtitleFontSize * 0.9,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.008,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(borderRadius * 0.8),
            ),
            child: Text(
              exerciseCount > 0
                  ? AppLocalizations.of(context)!.ready
                  : AppLocalizations.of(context)!.empty,
              style: TextStyle(
                fontSize: subtitleFontSize * 0.85,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(List<Exercise> exercises, double screenWidth, double screenHeight) {
    final titleFontSize = screenWidth * 0.05;
    final cardSpacing = screenHeight * 0.015;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.exercises,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: cardSpacing),
              child: _buildExerciseCard(exercise, index + 1, screenWidth, screenHeight),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, int number, double screenWidth, double screenHeight) {
    final cardPadding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.048;
    final subtitleFontSize = screenWidth * 0.038;
    final iconSize = screenWidth * 0.05;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Row(
            children: [
              Container(
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: titleFontSize * 0.9,
                      fontWeight: FontWeight.bold,
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
                      exercise.name,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Row(
                      children: [
                        _buildExerciseTag(exercise.muscle,
                            Theme.of(context).colorScheme.secondary, screenWidth),
                        SizedBox(width: screenWidth * 0.02),
                        _buildExerciseTag(exercise.difficulty,
                            _getDifficultyColor(exercise.difficulty), screenWidth),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Exercise Details
          Wrap(
            spacing: screenWidth * 0.04,
            runSpacing: screenHeight * 0.015,
            children: [
              _buildExerciseDetail(Icons.repeat,
                  AppLocalizations.of(context)!.sets, '${exercise.sets}', screenWidth, screenHeight),
              _buildExerciseDetail(Icons.fitness_center,
                  AppLocalizations.of(context)!.reps, '${exercise.reps}', screenWidth, screenHeight),
              if (exercise.weight != null)
                _buildExerciseDetail(
                    Icons.line_weight,
                    AppLocalizations.of(context)!.weight,
                    '${exercise.weight}kg', screenWidth, screenHeight),
              if (exercise.duration != null)
                _buildExerciseDetail(
                    Icons.timer,
                    AppLocalizations.of(context)!.duration,
                    '${exercise.duration}s', screenWidth, screenHeight),
            ],
          ),

          if (exercise.equipment.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.015),
            Row(
              children: [
                Icon(Icons.build,
                    size: iconSize * 0.7,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6)),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    'Equipment: ${exercise.equipment}',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (exercise.instructions.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.02),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                AppLocalizations.of(context)!.instructions,
                style: TextStyle(
                  fontSize: subtitleFontSize * 1.1,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              children: [
                SizedBox(height: screenHeight * 0.01),
                Text(
                  exercise.instructions,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],

          if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
            SizedBox(height: screenHeight * 0.015),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(borderRadius * 0.5),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.3),
                    width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note,
                      size: iconSize * 0.7, color: Theme.of(context).colorScheme.secondary),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      exercise.notes!,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
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

  Widget _buildExerciseTag(String text, Color color, double screenWidth) {
    final fontSize = screenWidth * 0.032;
    final padding = screenWidth * 0.02;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildExerciseDetail(IconData icon, String label, String value, double screenWidth, double screenHeight) {
    final iconSize = screenWidth * 0.05;
    final valueFontSize = screenWidth * 0.038;
    final labelFontSize = screenWidth * 0.032;

    return Column(
      children: [
        Icon(icon,
            size: iconSize,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        SizedBox(height: screenHeight * 0.005),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildNoExercisesMessage(double screenWidth, double screenHeight) {
    final padding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.04;
    final iconSize = screenWidth * 0.12;
    final titleFontSize = screenWidth * 0.045;
    final bodyFontSize = screenWidth * 0.038;

    return Container(
      margin: EdgeInsets.all(padding),
      padding: EdgeInsets.all(padding * 1.5),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: iconSize,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            AppLocalizations.of(context)!.noExercisesAvailable,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'No exercises have been assigned for this day yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.08;
    final iconSize = screenWidth * 0.16;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.04;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: iconSize,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              AppLocalizations.of(context)!.noDataAvailable,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'Unable to load workout data for this day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.08;
    final iconSize = screenWidth * 0.16;
    final titleFontSize = screenWidth * 0.05;
    final bodyFontSize = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.05;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: iconSize,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton.icon(
              onPressed: () {
                context.read<WorkoutDayProvider>().fetchWorkoutDay(
                      widget.weekNumber,
                      widget.dayNumber,
                    );
              },
              icon: Icon(Icons.refresh, size: screenWidth * 0.048),
              label: Text(AppLocalizations.of(context)!.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06, vertical: screenHeight * 0.015),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Day? _getLocalDayData() {
    try {
      final week = widget.workoutPlan.plan.weeks.firstWhere(
        (w) => w.weekNumber == widget.weekNumber,
      );
      return week.days.firstWhere(
        (d) => d.dayNumber == widget.dayNumber,
      );
    } catch (e) {
      return null;
    }
  }

  PlanMeta _getPlanMetaFromLocal() {
    return PlanMeta(
      name: widget.workoutPlan.plan.name,
      goal: widget.workoutPlan.plan.goal,
      level: widget.workoutPlan.plan.level,
      duration: widget.workoutPlan.plan.duration,
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
