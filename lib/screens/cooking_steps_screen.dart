import 'package:flutter/material.dart';

class CookingStepsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const CookingStepsScreen({super.key, required this.recipe});

  @override
  State<CookingStepsScreen> createState() => _CookingStepsScreenState();
}

class _CookingStepsScreenState extends State<CookingStepsScreen> {
  int _currentStep = 0;
  bool _isCompleted = false;
  List<bool> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    final steps = widget.recipe['cookingSteps'] as List<String>;
    _completedSteps = List.filled(steps.length, false);
  }

  void _nextStep() {
    final steps = widget.recipe['cookingSteps'] as List<String>;
    if (_currentStep < steps.length - 1) {
      setState(() {
        _completedSteps[_currentStep] = true;
        _currentStep++;
      });
    } else {
      setState(() {
        _completedSteps[_currentStep] = true;
        _isCompleted = true;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _completedSteps[_currentStep] = false;
        _currentStep--;
        _isCompleted = false;
      });
    }
  }

  void _goToStep(int stepIndex) {
    setState(() {
      // Mark all previous steps as completed
      for (int i = 0; i < stepIndex; i++) {
        _completedSteps[i] = true;
      }
      // Mark current and future steps as incomplete
      for (int i = stepIndex; i < _completedSteps.length; i++) {
        _completedSteps[i] = false;
      }
      _currentStep = stepIndex;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Responsive dimensions
    final appBarHeight = screenHeight * 0.08;
    final titleFontSize = screenWidth * 0.05;
    final stepNumberSize = screenWidth * 0.08;
    final stepTextSize = screenWidth * 0.04;
    final buttonTextSize = screenWidth * 0.035;
    final padding = screenWidth * 0.04;

    final steps = widget.recipe['cookingSteps'] as List<String>;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
              size: screenWidth * 0.06,
            ),
          ),
          title: Text(
            'Cooking Steps',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                _showStepsOverview(context);
              },
              icon: Icon(
                Icons.list,
                color: Theme.of(context).colorScheme.primary,
                size: screenWidth * 0.06,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Recipe Header
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Recipe Image
                Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    child: Image.network(
                      widget.recipe['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.recipe['color'].withOpacity(0.3),
                                widget.recipe['color'].withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                              size: screenWidth * 0.06,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: screenWidth * 0.03),

                // Recipe Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe['title'],
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        widget.recipe['subtitle'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.access_time,
                            widget.recipe['time'],
                            widget.recipe['color'],
                            screenWidth,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          _buildInfoChip(
                            Icons.bar_chart,
                            widget.recipe['difficulty'],
                            widget.recipe['color'],
                            screenWidth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress Indicator
          Container(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${steps.length}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      _isCompleted
                          ? 'Completed!'
                          : '${(((_currentStep + 1) / steps.length) * 100).round()}%',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: _isCompleted
                            ? Colors.green
                            : widget.recipe['color'],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                LinearProgressIndicator(
                  value: _isCompleted ? 1.0 : (_currentStep + 1) / steps.length,
                  backgroundColor:
                      Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isCompleted ? Colors.green : widget.recipe['color'],
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Current Step Display
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: padding),
              child: _isCompleted
                  ? _buildCompletionView(screenWidth, screenHeight)
                  : _buildCurrentStep(screenWidth, screenHeight, steps),
            ),
          ),

          // Navigation Buttons
          if (!_isCompleted)
            SafeArea(
              bottom: true,
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _previousStep,
                          icon: Icon(Icons.arrow_back,
                              color: widget.recipe['color']),
                          label: Text(
                            'Previous',
                            style: TextStyle(
                              color: widget.recipe['color'],
                              fontSize: buttonTextSize,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: widget.recipe['color']),
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      flex: _currentStep > 0 ? 1 : 2,
                      child: ElevatedButton.icon(
                        onPressed: _nextStep,
                        icon: Icon(
                          _currentStep == steps.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(
                          _currentStep == steps.length - 1
                              ? 'Complete'
                              : 'Next Step',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonTextSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.recipe['color'],
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(
      double screenWidth, double screenHeight, List<String> steps) {
    return Card(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Number Circle
            Center(
              child: Container(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.recipe['color'],
                  boxShadow: [
                    BoxShadow(
                      color: widget.recipe['color'].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${_currentStep + 1}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${_currentStep + 1}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: widget.recipe['color'],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      steps[_currentStep],
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Tips section (you can customize this per recipe)
                    if (_currentStep == 0)
                      _buildTipCard(
                        'Tip',
                        'Take your time to read through all ingredients before starting.',
                        Icons.lightbulb,
                        Colors.amber,
                        screenWidth,
                        screenHeight,
                      ),
                    if (_currentStep == steps.length - 1)
                      _buildTipCard(
                        'Serving Suggestion',
                        'Let the dish rest for a minute before serving for best taste.',
                        Icons.restaurant,
                        Colors.green,
                        screenWidth,
                        screenHeight,
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

  Widget _buildCompletionView(double screenWidth, double screenHeight) {
    return Card(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Animation
            Container(
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: screenWidth * 0.1,
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            Text(
              'You\'ve completed cooking ${widget.recipe['title']}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Snackbar removed - no longer showing save confirmation messages
                    },
                    icon: const Icon(Icons.bookmark, color: Colors.white),
                    label: Text(
                      'Save to History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                        _isCompleted = false;
                        _completedSteps =
                            List.filled(_completedSteps.length, false);
                      });
                    },
                    icon: Icon(Icons.replay, color: widget.recipe['color']),
                    label: Text(
                      'Cook Again',
                      style: TextStyle(
                        color: widget.recipe['color'],
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.recipe['color']),
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon, Color color,
      double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon, String text, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.035, color: color),
          SizedBox(width: screenWidth * 0.01),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showStepsOverview(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final steps = widget.recipe['cookingSteps'] as List<String>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: screenHeight * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screenWidth * 0.06),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.02),
              width: screenWidth * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                children: [
                  Text(
                    'All Steps',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Steps List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final isCompleted = _completedSteps[index];
                  final isCurrent = index == _currentStep && !_isCompleted;

                  return Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _goToStep(index);
                      },
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? widget.recipe['color'].withOpacity(0.1)
                              : isCompleted
                                  ? Colors.green.withOpacity(0.1)
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          border: Border.all(
                            color: isCurrent
                                ? widget.recipe['color']
                                : isCompleted
                                    ? Colors.green
                                    : Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Colors.green
                                    : isCurrent
                                        ? widget.recipe['color']
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.3),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? Icon(Icons.check,
                                        color: Colors.white,
                                        size: screenWidth * 0.04)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isCurrent
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                steps[index],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
