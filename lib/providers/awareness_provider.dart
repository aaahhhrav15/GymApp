import 'package:flutter/foundation.dart';

class AwarenessBlog {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime publishDate;
  final int readTimeMinutes;
  final List<String> tags;
  final Map<String, dynamic> costData;
  final List<String> keyPoints;
  final String severity; // 'low', 'medium', 'high', 'critical'

  AwarenessBlog({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.publishDate,
    required this.readTimeMinutes,
    required this.tags,
    required this.costData,
    required this.keyPoints,
    required this.severity,
  });

  factory AwarenessBlog.fromJson(Map<String, dynamic> json) {
    return AwarenessBlog(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'] ?? '',
      publishDate: json['publishDate'] != null
          ? DateTime.parse(json['publishDate'])
          : DateTime.now(),
      readTimeMinutes: json['readTimeMinutes'] ?? 5,
      tags: List<String>.from(json['tags'] ?? []),
      costData: Map<String, dynamic>.from(json['costData'] ?? {}),
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      severity: json['severity'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'publishDate': publishDate.toIso8601String(),
      'readTimeMinutes': readTimeMinutes,
      'tags': tags,
      'costData': costData,
      'keyPoints': keyPoints,
      'severity': severity,
    };
  }
}

class AwarenessProvider with ChangeNotifier {
  List<AwarenessBlog> _blogs = [];
  List<AwarenessBlog> _filteredBlogs = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AwarenessBlog> get blogs => _filteredBlogs;
  List<String> get categories => [
        'All',
        'Smoking',
        'Alcohol',
        'Poor Diet',
        'Sedentary Lifestyle',
        'Sleep Disorders',
        'Stress',
        'Mental Health'
      ];
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider with mock blog data
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading
      _loadMockBlogs();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load awareness content: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load mock blog data
  void _loadMockBlogs() {
    _blogs = [
      AwarenessBlog(
        id: '1',
        title: 'The Hidden Cost of Smoking: More Than Just Your Health',
        category: 'Smoking',
        summary:
            'Smoking doesn\'t just harm your health—it drains your wallet. Discover the shocking financial impact of this deadly habit.',
        content: '''
Smoking is one of the most expensive habits you can have, and not just because of the immediate cost of cigarettes. The long-term financial burden is staggering.

**Immediate Costs:**
• Average smoker spends \$2,000-4,000 per year on cigarettes
• Lost productivity due to smoke breaks
• Higher insurance premiums

**Health-Related Costs:**
• Lung cancer treatment: \$150,000-200,000
• Heart disease treatment: \$100,000-300,000
• COPD treatment: \$50,000-100,000 annually
• Stroke recovery: \$140,000-230,000

**Hidden Costs:**
• Dental problems: \$5,000-15,000
• Premature aging treatments
• Lost work days due to illness
• Higher life insurance rates

**The Solution:**
Quitting smoking is the best investment you can make. Within just one year, you'll save thousands while dramatically improving your health prospects.
        ''',
        imageUrl:
            'https://images.unsplash.com/photo-1544027993-37dbfe43562a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        author: 'Dr. Sarah Johnson',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        readTimeMinutes: 6,
        tags: ['smoking', 'health costs', 'financial impact', 'lung cancer'],
        costData: {
          'annualCigaretteCost': 3000.0,
          'averageTreatmentCost': 175000.0,
          'insurancePremiumIncrease': 1500.0,
          'totalLifetimeCost': 600000.0,
        },
        keyPoints: [
          'Smoking costs the average person over \$600,000 in their lifetime',
          'Lung cancer treatment can cost up to \$200,000',
          'Quitting smoking saves \$3,000+ annually',
          '90% of lung cancers are caused by smoking',
        ],
        severity: 'critical',
      ),
      AwarenessBlog(
        id: '2',
        title: 'Alcohol Abuse: The Silent Destroyer of Health and Wealth',
        category: 'Alcohol',
        summary:
            'Excessive alcohol consumption leads to serious health complications and enormous medical bills.',
        content: '''
Excessive alcohol consumption is a leading cause of preventable death and a major drain on personal finances.

**Health Consequences:**
• Liver disease (cirrhosis, hepatitis)
• Increased risk of cancer
• Heart problems
• Brain damage
• Digestive issues

**Financial Impact:**
• Alcohol purchases: \$1,500-5,000 annually
• DUI costs: \$10,000-15,000
• Liver transplant: \$500,000+
• Alcohol rehab: \$30,000-80,000

**Social Costs:**
• Lost job opportunities
• Relationship problems
• Legal issues
• Accidents and injuries

**Recovery Benefits:**
Reducing alcohol consumption or quitting entirely can save tens of thousands of dollars while dramatically improving your quality of life.
        ''',
        imageUrl:
            'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        author: 'Dr. Michael Chen',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        readTimeMinutes: 7,
        tags: ['alcohol', 'liver disease', 'addiction', 'financial burden'],
        costData: {
          'annualAlcoholCost': 3000.0,
          'duiCost': 12500.0,
          'liverTransplantCost': 500000.0,
          'rehabCost': 55000.0,
        },
        keyPoints: [
          'Liver disease affects 1 in 10 heavy drinkers',
          'DUI can cost over \$12,500 in fines and fees',
          'Liver transplant costs up to \$500,000',
          'Early intervention saves lives and money',
        ],
        severity: 'high',
      ),
      AwarenessBlog(
        id: '3',
        title: 'Poor Diet: The Slow Poison That Costs You Everything',
        category: 'Poor Diet',
        summary:
            'A poor diet leads to obesity, diabetes, and heart disease—conditions that can bankrupt you.',
        content: '''
Poor dietary habits are responsible for more deaths globally than smoking, and the financial burden is enormous.

**Health Risks:**
• Type 2 diabetes
• Heart disease
• Stroke
• Certain cancers
• Obesity

**Medical Costs:**
• Diabetes management: \$13,000 annually
• Heart bypass surgery: \$200,000
• Stroke treatment: \$140,000
• Obesity-related treatments: \$3,000-5,000 annually

**Hidden Costs:**
• Lost productivity
• Disability insurance
• Specialized medical equipment
• Frequent doctor visits

**Prevention is Cheaper:**
Investing in healthy food and nutrition education costs far less than treating diet-related diseases.
        ''',
        imageUrl:
            'https://images.unsplash.com/photo-1490645935967-10de6ba17061?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2053&q=80',
        author: 'Dr. Emily Rodriguez',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        readTimeMinutes: 5,
        tags: ['diet', 'diabetes', 'heart disease', 'obesity'],
        costData: {
          'diabetesCost': 13000.0,
          'heartSurgeryCost': 200000.0,
          'strokeCost': 140000.0,
          'obesityTreatment': 4000.0,
        },
        keyPoints: [
          'Poor diet causes 11 million deaths annually worldwide',
          'Diabetes costs \$13,000+ per year to manage',
          'Heart disease is the leading cause of death globally',
          'Healthy eating can prevent 80% of heart disease cases',
        ],
        severity: 'high',
      ),
      AwarenessBlog(
        id: '4',
        title: 'Sedentary Lifestyle: Sitting Your Way to Disease',
        category: 'Sedentary Lifestyle',
        summary:
            'Lack of physical activity increases your risk of chronic diseases and expensive medical treatments.',
        content: '''
A sedentary lifestyle is as dangerous as smoking and leads to numerous expensive health problems.

**Health Consequences:**
• Cardiovascular disease
• Type 2 diabetes
• Certain cancers
• Depression and anxiety
• Osteoporosis

**Economic Impact:**
• Heart disease treatment: \$100,000+
• Diabetes management: \$13,000 annually
• Cancer treatment: \$150,000-1,000,000
• Mental health treatment: \$3,000-10,000 annually

**Productivity Losses:**
• Increased sick days
• Reduced work performance
• Early retirement due to illness
• Higher insurance premiums

**The Solution:**
Just 150 minutes of moderate exercise per week can dramatically reduce your risk and save thousands in medical costs.
        ''',
        imageUrl:
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2069&q=80',
        author: 'Dr. James Wilson',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        readTimeMinutes: 6,
        tags: ['exercise', 'sedentary', 'heart disease', 'prevention'],
        costData: {
          'heartDiseaseCost': 125000.0,
          'diabetesCost': 13000.0,
          'cancerTreatment': 575000.0,
          'mentalHealthCost': 6500.0,
        },
        keyPoints: [
          'Sedentary lifestyle increases death risk by 147%',
          '150 minutes of exercise per week can prevent most diseases',
          'Physical inactivity costs \$117 billion annually in the US',
          'Regular exercise adds 3-5 years to your life',
        ],
        severity: 'medium',
      ),
      AwarenessBlog(
        id: '5',
        title: 'Sleep Disorders: The Silent Epidemic Draining Your Health',
        category: 'Sleep Disorders',
        summary:
            'Poor sleep quality leads to serious health issues and significant medical expenses.',
        content: '''
Sleep disorders affect millions and lead to serious health complications and enormous costs.

**Health Impacts:**
• Cardiovascular disease
• Diabetes
• Obesity
• Weakened immune system
• Mental health issues

**Medical Costs:**
• Sleep study: \$3,000-5,000
• CPAP machine: \$1,500-3,000
• Sleep disorder treatment: \$5,000-15,000 annually
• Related condition treatments: \$20,000+ annually

**Economic Consequences:**
• Workplace accidents
• Reduced productivity
• Increased absenteeism
• Higher insurance costs

**Benefits of Good Sleep:**
Quality sleep improves health, productivity, and can save thousands in medical expenses.
        ''',
        imageUrl:
            'https://images.unsplash.com/photo-1520206183501-b80df61043c2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        author: 'Dr. Lisa Park',
        publishDate: DateTime.now().subtract(const Duration(days: 4)),
        readTimeMinutes: 5,
        tags: ['sleep', 'sleep apnea', 'insomnia', 'health costs'],
        costData: {
          'sleepStudyCost': 4000.0,
          'cpapCost': 2250.0,
          'treatmentCost': 10000.0,
          'relatedConditions': 25000.0,
        },
        keyPoints: [
          '70% of adults don\'t get enough quality sleep',
          'Sleep disorders cost \$16 billion annually in healthcare',
          'Poor sleep increases disease risk by 300%',
          'Good sleep hygiene can prevent most sleep disorders',
        ],
        severity: 'medium',
      ),
      AwarenessBlog(
        id: '6',
        title: 'Chronic Stress: The Modern Killer That Costs You Everything',
        category: 'Stress',
        summary:
            'Chronic stress leads to numerous health problems and expensive treatments.',
        content: '''
Chronic stress is a silent killer that contributes to most major diseases and costs billions in healthcare.

**Health Effects:**
• Heart disease
• High blood pressure
• Diabetes
• Mental health disorders
• Weakened immune system

**Financial Impact:**
• Stress-related medical costs: \$300 billion annually
• Individual treatment costs: \$5,000-20,000 yearly
• Lost productivity: \$125 billion annually
• Medication costs: \$2,000-5,000 yearly

**Hidden Costs:**
• Increased accidents
• Poor decision making
• Relationship problems
• Substance abuse

**Stress Management:**
Learning to manage stress effectively can prevent diseases and save thousands in medical costs.
        ''',
        imageUrl:
            'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2094&q=80',
        author: 'Dr. Robert Martinez',
        publishDate: DateTime.now().subtract(const Duration(days: 6)),
        readTimeMinutes: 7,
        tags: ['stress', 'mental health', 'heart disease', 'prevention'],
        costData: {
          'annualTreatmentCost': 12500.0,
          'medicationCost': 3500.0,
          'lostProductivity': 8000.0,
          'totalImpact': 50000.0,
        },
        keyPoints: [
          'Chronic stress affects 77% of people regularly',
          'Stress-related illnesses cost \$300 billion annually',
          'Stress increases heart disease risk by 40%',
          'Stress management can reduce medical costs by 50%',
        ],
        severity: 'high',
      ),
    ];
  }

  /// Filter blogs by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Search blogs by query
  void searchBlogs(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters
  void _applyFilters() {
    _filteredBlogs = _blogs.where((blog) {
      final matchesCategory =
          _selectedCategory == 'All' || blog.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          blog.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          blog.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesCategory && matchesSearch;
    }).toList();

    // Sort by publish date (newest first)
    _filteredBlogs.sort((a, b) => b.publishDate.compareTo(a.publishDate));
  }

  /// Get blog by ID
  AwarenessBlog? getBlogById(String id) {
    try {
      return _blogs.firstWhere((blog) => blog.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get blogs by severity
  List<AwarenessBlog> getBlogsBySeverity(String severity) {
    return _blogs.where((blog) => blog.severity == severity).toList();
  }

  /// Get total estimated cost savings by avoiding all bad habits
  double getTotalPotentialSavings() {
    double total = 0;
    for (var blog in _blogs) {
      final costData = blog.costData;
      if (costData.containsKey('totalLifetimeCost')) {
        total += (costData['totalLifetimeCost'] as num).toDouble();
      } else {
        // Estimate based on available cost data
        double blogTotal = 0;
        costData.forEach((key, value) {
          if (value is num && key.toLowerCase().contains('cost')) {
            blogTotal += value.toDouble();
          }
        });
        total += blogTotal;
      }
    }
    return total;
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }
}
