import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CitationsScreen extends StatelessWidget {
  const CitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical References'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCitationCard(
            context,
            'BMI Calculation Standards',
            'World Health Organization (WHO)',
            'https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight',
            'Body Mass Index (BMI) calculations and classifications are based on WHO standards for adults aged 18-65 years.',
          ),
          _buildCitationCard(
            context,
            'Nutritional Guidelines',
            'USDA Dietary Guidelines for Americans',
            'https://www.dietaryguidelines.gov/',
            'Daily nutritional recommendations, macronutrient ratios, and micronutrient requirements are based on USDA guidelines.',
          ),
          _buildCitationCard(
            context,
            'Physical Activity Recommendations',
            'American Heart Association (AHA)',
            'https://www.heart.org/en/healthy-living/fitness/fitness-basics/aha-recs-for-physical-activity-in-adults',
            'Exercise intensity, duration, and frequency recommendations follow AHA guidelines for cardiovascular health.',
          ),
          _buildCitationCard(
            context,
            'Sleep Health Guidelines',
            'National Sleep Foundation',
            'https://www.sleepfoundation.org/how-sleep-works/how-much-sleep-do-we-really-need',
            'Sleep duration recommendations and sleep quality metrics are based on National Sleep Foundation guidelines.',
          ),
          _buildCitationCard(
            context,
            'Hydration Guidelines',
            'Institute of Medicine (IOM)',
            'https://www.nap.edu/read/10925/chapter/6',
            'Daily water intake recommendations are based on IOM dietary reference intakes for water.',
          ),
          _buildCitationCard(
            context,
            'Step Counting Accuracy',
            'American College of Sports Medicine (ACSM)',
            'https://www.acsm.org/',
            'Step counting methodology and activity tracking accuracy standards follow ACSM guidelines.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Disclaimer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This app provides general health and fitness information for educational purposes only. It is not intended to replace professional medical advice, diagnosis, or treatment. Always consult with a qualified healthcare provider before making significant changes to your diet or exercise routine.',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationCard(
    BuildContext context,
    String title,
    String source,
    String url,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Source: $source',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(url),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View Source'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
