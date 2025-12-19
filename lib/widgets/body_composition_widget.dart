import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/providers/body_composition_provider.dart';
import 'package:gym_app_2/services/bluetooth_permission_service.dart';

class BodyCompositionWidget extends StatefulWidget {
  const BodyCompositionWidget({Key? key}) : super(key: key);

  @override
  State<BodyCompositionWidget> createState() => _BodyCompositionWidgetState();
}

class _BodyCompositionWidgetState extends State<BodyCompositionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BodyCompositionProvider>().fetchBodyComposition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<BodyCompositionProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () async {
            // Check permissions and navigate to body composition screen
            await BluetoothPermissionService.checkAndNavigateToBodyComposition(
                context);
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal:
                  0, // Remove horizontal margin to align with other widgets
              vertical: screenHeight * 0.01,
            ),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF1E3A8A), // Dark blue
                        const Color(0xFF3B82F6), // Medium blue
                        const Color(0xFF06B6D4), // Cyan
                      ]
                    : [
                        const Color(0xFF3B82F6), // Blue
                        const Color(0xFF06B6D4), // Cyan
                        const Color(0xFF10B981), // Green
                      ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? const Color(0xFF3B82F6).withOpacity(0.3)
                      : const Color(0xFF06B6D4).withOpacity(0.3),
                  blurRadius: screenWidth * 0.04, // Responsive blur radius
                  offset: Offset(0, screenWidth * 0.02), // Responsive offset
                  spreadRadius: screenWidth * 0.005, // Responsive spread
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: screenHeight * 0.02),
                if (provider.isLoading)
                  _buildLoadingState(context)
                else if (provider.errorMessage != null)
                  _buildErrorState(context, provider.errorMessage!)
                else if (provider.currentComposition != null)
                  _buildMetricsGrid(context, provider)
                else
                  _buildEmptyState(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.025),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: screenWidth * 0.002, // Responsive border width
            ),
          ),
          child: Icon(
            Icons.analytics_outlined,
            size: screenWidth * 0.06,
            color: Colors.white,
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Body Composition',
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'View detailed metrics',
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.015),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: screenWidth * 0.04,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              child: CircularProgressIndicator(
                strokeWidth: screenWidth * 0.005, // Responsive stroke width
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Text(
              'Loading body composition...',
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Reduced font size
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.06, // Reduced icon size
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Reduced font size
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_chart_outlined,
              size: screenWidth * 0.06, // Reduced icon size
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'No measurements yet',
              style: TextStyle(
                fontSize: screenWidth * 0.03, // Reduced font size
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(
      BuildContext context, BodyCompositionProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final composition = provider.currentComposition!;

    // Key metrics to display on home screen
    final keyMetrics = [
      _KeyMetric(
        title: 'Weight',
        value: composition.weight,
        unit: 'kg',
        status: composition.weightStatus,
        icon: Icons.monitor_weight_outlined,
      ),
      _KeyMetric(
        title: 'Body fat',
        value: composition.bodyFat,
        unit: '%',
        status: composition.bodyFatStatus,
        icon: Icons.pie_chart,
      ),
      _KeyMetric(
        title: 'Fat free body weight',
        value: composition.fatFreeBodyWeight,
        unit: 'kg',
        status: composition.fatFreeBodyWeightStatus,
        icon: Icons.straighten_outlined,
      ),
      _KeyMetric(
        title: 'Muscle rate',
        value: composition.muscleRate,
        unit: '%',
        status: composition.muscleRateStatus,
        icon: Icons.fitness_center_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            screenWidth > 400 ? 2.4 : 2.0, // Responsive aspect ratio
        crossAxisSpacing: screenWidth * 0.025, // Reduced spacing
        mainAxisSpacing: screenHeight * 0.01, // Reduced spacing
      ),
      itemCount: keyMetrics.length,
      itemBuilder: (context, index) {
        return _buildMetricItem(context, keyMetrics[index]);
      },
    );
  }

  Widget _buildMetricItem(BuildContext context, _KeyMetric metric) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final formattedValue =
        BodyCompositionProvider.getFormattedValue(metric.value, metric.unit);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDarkMode ? 0.1 : 0.2),
        borderRadius:
            BorderRadius.circular(screenWidth * 0.02), // Reduced border radius
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: screenWidth * 0.002, // Responsive border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: screenWidth * 0.01, // Responsive blur radius
            offset: Offset(0, screenWidth * 0.005), // Responsive offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.01), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.01), // Reduced radius
                ),
                child: Icon(
                  metric.icon,
                  size: screenWidth * 0.035, // Reduced icon size
                  color: Colors.white,
                ),
              ),
              SizedBox(width: screenWidth * 0.015), // Reduced spacing
              Expanded(
                child: Text(
                  metric.title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.025, // Reduced font size
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Allow 2 lines for longer text
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.015, // Reduced padding
                  vertical: screenWidth * 0.008, // Reduced padding
                ),
                decoration: BoxDecoration(
                  color:
                      _getStatusBackgroundColor(metric.status).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.01), // Reduced radius
                ),
                child: Text(
                  metric.status,
                  style: TextStyle(
                    fontSize: screenWidth * 0.022, // Reduced font size
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                // Use Flexible instead of fixed Text
                child: Text(
                  formattedValue,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028, // Reduced font size
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'standard':
      case 'normal':
        return Colors.green;
      case 'high':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      case 'poor':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _KeyMetric {
  final String title;
  final double value;
  final String unit;
  final String status;
  final IconData icon;

  _KeyMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.icon,
  });
}
