// // lib/screens/nutrition_screen.dart - Updated to use NutritionProvider
// import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../providers/nutrition_provider.dart';
// import '../models/nutrition_models.dart';
// import '../components/nutrition_summary_card.dart';
// import '../components/meal_card.dart';
// import '../components/add_food_drawer.dart';

// class NutritionDetailScreen extends StatefulWidget {
//   const NutritionDetailScreen({super.key});

//   @override
//   State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
// }

// class _NutritionDetailScreenState extends State<NutritionDetailScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _drawerAnimationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _drawerAnimation;

//   bool _showAddFoodDrawer = false;
//   bool _isAddingFood = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();

//     // Initialize provider
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NutritionProvider>().initialize();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _drawerAnimationController.dispose();
//     super.dispose();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _drawerAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     _drawerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _drawerAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _animationController.forward();
//   }

//   void _toggleAddFoodDrawer() {
//     setState(() {
//       _showAddFoodDrawer = !_showAddFoodDrawer;
//     });

//     if (_showAddFoodDrawer) {
//       _drawerAnimationController.forward();
//     } else {
//       _drawerAnimationController.reverse();
//     }
//   }

//   Future<void> _addFood({
//     required String name,
//     required int calories,
//     required double protein,
//     required double fat,
//     required double carbs,
//     String mealType = 'custom',
//     String source = 'manual',
//   }) async {
//     if (_isAddingFood) return;

//     setState(() => _isAddingFood = true);

//     try {
//       final meal = Meal(
//         name: name,
//         calories: calories,
//         protein: protein,
//         fat: fat,
//         carbs: carbs,
//         mealType: mealType,
//         time: DateTime.now().toString(),
//         createdAt: DateTime.now(),
//         source: source,
//       );

//       await context.read<NutritionProvider>().addMeal(meal);

//       if (mounted) {
//         _toggleAddFoodDrawer();
//         // ScaffoldMessenger.of(context).showSnackBar(
         // //           const SnackBar(
         // //             content: Text('Food added successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
         // //           SnackBar(
         // //             content: Text('Failed to add food: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isAddingFood = false);
//       }
//     }
//   }

//   Future<void> _deleteMeal(Meal meal) async {
//     try {
//       if (meal.id != null) {
//         await context.read<NutritionProvider>().deleteMeal(meal.id!);

//         if (mounted) {
//           // ScaffoldMessenger.of(context).showSnackBar(
           // //             const SnackBar(
           // //               content: Text('Meal deleted successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
         // //           SnackBar(
         // //             content: Text('Failed to delete meal: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<NutritionProvider>(
//       builder: (context, nutritionProvider, child) {
//         return Scaffold(
//           backgroundColor: const Color(0xFF0A0E21),
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 // Main content
//                 Column(
//                   children: [
//                     // Header
//                     _buildHeader(context, nutritionProvider),

//                     // Body
//                     Expanded(
//                       child: nutritionProvider.isLoading
//                           ? const Center(
//                               child: CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                     Color(0xFF8BC34A)),
//                               ),
//                             )
//                           : FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: Column(
//                                 children: [
//                                   // Nutrition summary card
//                                   Padding(
//                                     padding: const EdgeInsets.all(16.0),
//                                     child: NutritionSummaryCard(
//                                       currentTotals:
//                                           nutritionProvider.currentTotals,
//                                       goals: nutritionProvider.nutritionGoals,
//                                     ),
//                                   ),

//                                   // Meals list
//                                   Expanded(
//                                     child: _buildMealsList(nutritionProvider),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),

//                 // Add food button
//                 Positioned(
//                   bottom: 20,
//                   right: 20,
//                   child: FloatingActionButton(
//                     backgroundColor: const Color(0xFF8BC34A),
//                     onPressed: nutritionProvider.isLoading
//                         ? null
//                         : _toggleAddFoodDrawer,
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: _showAddFoodDrawer
//                           ? const Icon(Icons.close, key: ValueKey('close'))
//                           : const Icon(Icons.add, key: ValueKey('add')),
//                     ),
//                   ),
//                 ),

//                 // Add food drawer
//                 if (_showAddFoodDrawer)
//                   SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0, 1),
//                       end: Offset.zero,
//                     ).animate(_drawerAnimationController),
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.8,
//                       width: double.infinity,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF1D1E33),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: AddFoodDrawer(
//                         animation: _drawerAnimation,
//                         onClose: _toggleAddFoodDrawer,
//                         onAddFood: _addFood,
//                         isLoading: _isAddingFood,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader(
//       BuildContext context, NutritionProvider nutritionProvider) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           ),
//           const SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Nutrition',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 _formatDisplayDate(nutritionProvider.selectedDate),
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () {
//               // Refresh data for new day if needed
//               context.read<NutritionProvider>().refreshForNewDay();
//             },
//             icon: const Icon(Icons.refresh, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMealsList(NutritionProvider nutritionProvider) {
//     if (nutritionProvider.meals.isEmpty) {
//       return const Center(
//         child: Text(
//           'No meals added yet.\nTap the + button to add your first meal!',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 16,
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: nutritionProvider.meals.length,
//       itemBuilder: (context, index) {
//         final meal = nutritionProvider.meals[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12.0),
//           child: MealCard(
//             meal: meal,
//             onDelete: (mealToDelete) => _deleteMeal(mealToDelete),
//             onEdit: (updatedMeal) => _editMeal(meal.id!, updatedMeal),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _editMeal(String mealId, Meal updatedMeal) async {
//     try {
//       await context.read<NutritionProvider>().updateMeal(mealId, updatedMeal);

//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
         // //           const SnackBar(
         // //             content: Text('Meal updated successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         // ScaffoldMessenger.of(context).showSnackBar(
         // //           SnackBar(
         // //             content: Text('Failed to update meal: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   String _formatDisplayDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       final today = DateTime.now();

//       if (date.day == today.day &&
//           date.month == today.month &&
//           date.year == today.year) {
//         return 'Today';
//       }

//       final yesterday = today.subtract(const Duration(days: 1));
//       if (date.day == yesterday.day &&
//           date.month == yesterday.month &&
//           date.year == yesterday.year) {
//         return 'Yesterday';
//       }

//       final months = [
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'May',
//         'Jun',
//         'Jul',
//         'Aug',
//         'Sep',
//         'Oct',
//         'Nov',
//         'Dec'
//       ];
//       return '${months[date.month - 1]} ${date.day}, ${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }
