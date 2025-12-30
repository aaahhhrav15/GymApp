import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_app_2/models/user_model.dart';
import 'package:gym_app_2/providers/profile_provider.dart';
import 'package:gym_app_2/providers/theme_provider.dart';
import 'package:gym_app_2/providers/login_provider.dart';
import 'package:gym_app_2/providers/locale_provider.dart';
import '../services/profile_service.dart';
import '../l10n/app_localizations.dart';
import 'edit_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.fetchUserProfile();
      debugPrint(
          'ProfileScreen: Profile loaded - Status: ${profileProvider.syncStatus}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.hasError) {
            return _buildErrorState(l10n, profileProvider.error!);
          }

          final userProfile = profileProvider.userProfile;
          if (userProfile == null) {
            return _buildEmptyState(l10n);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await profileProvider.syncWithBackend();
            },
            child: CustomScrollView(
              slivers: [
                // Custom App Bar with Profile Header
                SliverToBoxAdapter(
                  child: _buildProfileHeader(l10n, userProfile, profileProvider),
                ),

                // Content
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Personal Information is now in the profile header

                      // Physical Stats Card
                      _buildPhysicalStatsCard(l10n, userProfile),

                      SizedBox(height: screenHeight * 0.02),

                      // Membership Card
                      _buildMembershipCard(l10n, userProfile),

                      SizedBox(height: screenHeight * 0.02),

                      // Settings Section
                      _buildSettingsCard(l10n),

                      SizedBox(height: screenHeight * 0.02),

                      // Account Actions
                      _buildAccountActionsCard(l10n),

                      SizedBox(height: screenHeight * 0.12),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      AppLocalizations l10n, UserProfile userProfile, ProfileProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.015,
        ),
        child: Column(
          children: [
            // Top Bar with Title and Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.profile,
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      if (result == true) {
                        provider.fetchUserProfile();
                      }
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: screenWidth * 0.055,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.025),

            // Profile Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image with gradient ring
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.01),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.008),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Container(
                        width: screenWidth * 0.35, // Increased from 0.26 to 0.35
                        height: screenWidth * 0.35, // Increased from 0.26 to 0.35
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: userProfile.profileImageUrl != null
                              ? Image.network(
                                  userProfile.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar(screenWidth);
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildLoadingAvatar(screenWidth);
                                  },
                                )
                              : _buildDefaultAvatar(screenWidth),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Name with clean styling
                  Text(
                    _toTitleCase(userProfile.name),
                    style: TextStyle(
                      fontSize: screenWidth * 0.062,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  // Phone Number with clean styling
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.045,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: screenWidth * 0.042,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Text(
                          userProfile.phone,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(AppLocalizations l10n, UserProfile userProfile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.028),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade400,
                      Colors.indigo.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.badge_rounded,
                  color: Colors.white,
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.035),
              Text(
                l10n.personalInformation,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // Info Grid
          Row(
            children: [
              // Gender
              Expanded(
                child: _buildInfoItem(
                  icon: userProfile.gender?.toLowerCase() == 'male'
                      ? Icons.male
                      : userProfile.gender?.toLowerCase() == 'female'
                          ? Icons.female
                          : Icons.person_outline,
                  label: l10n.gender,
                  value: userProfile.gender != null 
                      ? _capitalizeFirst(userProfile.gender!) 
                      : l10n.notSet,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              // Date of Birth
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.cake_outlined,
                  label: l10n.dateOfBirth,
                  value: userProfile.birthday != null
                      ? _formatDate(userProfile.birthday!)
                      : l10n.notSet,
                  color: Colors.pink,
                ),
              ),
            ],
          ),

          if (userProfile.birthday != null) ...[
            SizedBox(height: screenHeight * 0.015),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Text(
                  '${_calculateAge(userProfile.birthday!)} ${l10n.yearsOld}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.06),
          SizedBox(height: screenHeight * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalStatsCard(AppLocalizations l10n, UserProfile userProfile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.028),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.035),
              Text(
                "Body Metrics",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // Gender and Date of Birth Row
          Row(
            children: [
              // Gender
              Expanded(
                child: _buildStatCard(
                  icon: userProfile.gender?.toLowerCase() == 'male'
                      ? Icons.male
                      : userProfile.gender?.toLowerCase() == 'female'
                          ? Icons.female
                          : Icons.person_outline,
                  label: l10n.gender,
                  value: userProfile.gender != null 
                      ? _capitalizeFirst(userProfile.gender!) 
                      : l10n.notSet,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              // Date of Birth
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cake_outlined,
                  label: l10n.dateOfBirth,
                  value: userProfile.birthday != null
                      ? _formatDate(userProfile.birthday!)
                      : l10n.notSet,
                  color: Colors.pink,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Weight and Height Row
          Row(
            children: [
              // Weight
              Expanded(
                child: _buildStatCard(
                  icon: Icons.monitor_weight_outlined,
                  label: l10n.weight,
                  value: userProfile.weight != null
                      ? '${userProfile.weight!.toStringAsFixed(1)} kg'
                      : l10n.notSet,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              // Height
              Expanded(
                child: _buildStatCard(
                  icon: Icons.height_outlined,
                  label: l10n.height,
                  value: userProfile.height != null
                      ? '${userProfile.height!.toStringAsFixed(0)} cm'
                      : l10n.notSet,
                  color: Colors.teal,
                ),
              ),
            ],
          ),

          // Age and BMI Row at the bottom
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              // Age
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today_outlined,
                  label: "Age",
                  value: userProfile.birthday != null
                      ? '${_calculateAge(userProfile.birthday!)} ${l10n.yearsOld}'
                      : l10n.notSet,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              // BMI
              Expanded(
                child: _buildStatCard(
                  icon: Icons.accessibility_new,
                  label: l10n.bmiLabel,
                  value: userProfile.bmi != null
                      ? userProfile.bmi!.toStringAsFixed(1)
                      : l10n.notSet,
                  color: _getBmiColor(userProfile.bmi),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenHeight * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.06),
          SizedBox(height: screenHeight * 0.008),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.003),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(AppLocalizations l10n, UserProfile userProfile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.028),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.shade400,
                      Colors.teal.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.035),
              Text(
                l10n.membershipDetails,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Membership Info
          _buildMembershipRow(
            icon: Icons.badge_outlined,
            label: l10n.clubCode,
            value: userProfile.gymCode ?? l10n.notSet,
          ),
          if (userProfile.joinDate != null)
            _buildMembershipRow(
              icon: Icons.event_outlined,
              label: l10n.joinDate,
              value: _formatDate(userProfile.joinDate!),
            ),
          if (userProfile.membershipStartDate != null)
            _buildMembershipRow(
              icon: Icons.play_circle_outline,
              label: l10n.startDate,
              value: _formatDate(userProfile.membershipStartDate!),
            ),
          if (userProfile.membershipEndDate != null)
            _buildMembershipRow(
              icon: Icons.stop_circle_outlined,
              label: l10n.endDate,
              value: _formatDate(userProfile.membershipEndDate!),
            ),
          if (userProfile.membershipDuration != null)
            _buildMembershipRow(
              icon: Icons.timer_outlined,
              label: l10n.duration,
              value: l10n.months(userProfile.membershipDuration!),
            ),
          if (userProfile.membershipFees != null)
            _buildMembershipRow(
              icon: Icons.currency_rupee_outlined,
              label: l10n.fees,
              value: '₹${userProfile.membershipFees!.toStringAsFixed(0)}',
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildMembershipRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: screenWidth * 0.045,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.028),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.035),
              Text(
                l10n.settings,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Language Selector
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              String currentLang;
              if (localeProvider.locale.languageCode == 'en') {
                currentLang = l10n.english;
              } else if (localeProvider.locale.languageCode == 'hi') {
                currentLang = l10n.hindi;
              } else {
                currentLang = l10n.marathi;
              }
              return _buildSettingsTile(
                icon: Icons.language_outlined,
                iconColor: Colors.blue,
                label: l10n.language,
                value: currentLang,
                onTap: () => _showLanguageBottomSheet(l10n, localeProvider),
              );
            },
          ),

          SizedBox(height: screenHeight * 0.012),

          // Theme Selector
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final currentTheme = themeProvider.allThemeOptions(l10n)
                  .firstWhere((o) => o.mode == themeProvider.themeMode);
              return _buildSettingsTile(
                icon: Icons.palette_outlined,
                iconColor: Colors.orange,
                label: l10n.theme,
                value: currentTheme.title,
                trailing: Icon(
                  currentTheme.icon,
                  size: screenWidth * 0.045,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => _showThemeBottomSheet(l10n, themeProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.035,
            vertical: screenHeight * 0.015,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(
                  icon,
                  size: screenWidth * 0.05,
                  color: iconColor,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.003),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing,
                SizedBox(width: screenWidth * 0.02),
              ],
              Icon(
                Icons.chevron_right,
                size: screenWidth * 0.055,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(AppLocalizations l10n, LocaleProvider localeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(screenWidth * 0.06),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: screenWidth * 0.1,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.025),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        ),
                        child: Icon(
                          Icons.language_outlined,
                          color: Colors.blue,
                          size: screenWidth * 0.055,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        l10n.language,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  
                  // Language options
                  _buildLanguageOption(
                    flag: '🇺🇸',
                    title: l10n.english,
                    subtitle: 'English',
                    isSelected: localeProvider.locale.languageCode == 'en',
                    onTap: () {
                      localeProvider.setLocale(const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.012),
                  _buildLanguageOption(
                    flag: '🇮🇳',
                    title: l10n.hindi,
                    subtitle: 'हिंदी',
                    isSelected: localeProvider.locale.languageCode == 'hi',
                    onTap: () {
                      localeProvider.setLocale(const Locale('hi'));
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.012),
                  _buildLanguageOption(
                    flag: '🇮🇳',
                    title: l10n.marathi,
                    subtitle: 'मराठी',
                    isSelected: localeProvider.locale.languageCode == 'mr',
                    onTap: () {
                      localeProvider.setLocale(const Locale('mr'));
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.018,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(screenWidth * 0.035),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: TextStyle(fontSize: screenWidth * 0.08),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: screenWidth * 0.04,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeBottomSheet(AppLocalizations l10n, ThemeProvider themeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(screenWidth * 0.06),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: screenWidth * 0.1,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.025),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.025),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: Colors.orange,
                          size: screenWidth * 0.055,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        l10n.theme,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  
                  // Theme options
                  ...themeProvider.allThemeOptions(l10n).map((option) {
                    final isSelected = themeProvider.themeMode == option.mode;
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.012),
                      child: _buildThemeOption(
                        icon: option.icon,
                        title: option.title,
                        subtitle: _getThemeSubtitle(option.mode, l10n),
                        color: _getThemeColor(option.mode),
                        isSelected: isSelected,
                        onTap: () {
                          themeProvider.setThemeMode(option.mode);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getThemeSubtitle(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return 'Bright and clean appearance';
      case ThemeMode.dark:
        return 'Easy on the eyes at night';
      case ThemeMode.system:
        return 'Follows your device settings';
    }
  }

  Color _getThemeColor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Colors.amber;
      case ThemeMode.dark:
        return Colors.indigo;
      case ThemeMode.system:
        return Colors.teal;
    }
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.018,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(screenWidth * 0.035),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                ),
                child: Icon(
                  icon,
                  size: screenWidth * 0.06,
                  color: color,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: screenWidth * 0.04,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Delete Account Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteAccountDialog(),
            icon: Icon(
              Icons.delete_outline,
              size: screenWidth * 0.05,
            ),
            label: Text(
              l10n.deleteAccount,
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoggingOut ? null : () => _showLogoutDialog(),
            icon: _isLoggingOut
                ? SizedBox(
                    width: screenWidth * 0.04,
                    height: screenWidth * 0.04,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  )
                : Icon(Icons.logout, size: screenWidth * 0.05),
            label: Text(
              l10n.signOut,
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, String error) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
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
              l10n.somethingWentWrong,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileProvider>().refreshProfile();
              },
              icon: Icon(Icons.refresh, size: screenWidth * 0.04),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: screenWidth * 0.16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              l10n.noProfileData,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              l10n.unableToLoadProfile,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileProvider>().refreshProfile();
              },
              icon: Icon(Icons.refresh, size: screenWidth * 0.04),
              label: Text(l10n.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(_userProfile?.name ?? 'User'),
          style: TextStyle(
            fontSize: screenWidth * 0.1,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: SizedBox(
          width: screenWidth * 0.08,
          height: screenWidth * 0.08,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // Helper methods
  UserProfile? get _userProfile => context.read<ProfileProvider>().userProfile;

  /// Capitalizes the first letter of a string (e.g., "male" -> "Male")
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Converts a string to title case (e.g., "john doe" -> "John Doe")
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Color _getBmiColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  IconData _getBmiIcon(String? category) {
    if (category == null) return Icons.info_outline;
    switch (category.toLowerCase()) {
      case 'underweight':
        return Icons.trending_down;
      case 'normal weight':
        return Icons.check_circle_outline;
      case 'overweight':
        return Icons.trending_up;
      case 'obese':
        return Icons.warning_outlined;
      default:
        return Icons.info_outline;
    }
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          title: Text(
            l10n.signOut,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(l10n.areYouSureSignOut),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogout();
              },
              child: Text(
                l10n.signOut,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                l10n.deleteAccount,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deleteAccountConfirm),
              SizedBox(height: screenWidth * 0.03),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importantInformation,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      l10n.deleteAccountInfo,
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _launchDeleteAccountWebsite();
              },
              child: Text(
                l10n.continueToDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchDeleteAccountWebsite() async {
    final Uri deleteAccountUrl = Uri.parse(
        'https://mr-muscle-privacy-website.vercel.app/delete-account');

    try {
      if (await canLaunchUrl(deleteAccountUrl)) {
        await launchUrl(
          deleteAccountUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error opening deletion page: $e');
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ProfileService.signOut();

      if (mounted) {
        final loginProvider = Provider.of<LoginProvider>(context, listen: false);
        loginProvider.resetLoginState();

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        final loginProvider = Provider.of<LoginProvider>(context, listen: false);
        loginProvider.resetLoginState();

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }
}
