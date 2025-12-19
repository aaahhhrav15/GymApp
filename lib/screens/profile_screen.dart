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
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    // Initialize profile provider - first from local cache, then refresh from backend
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider = context.read<ProfileProvider>();

      // Load profile with connectivity-aware strategy
      // This will show local data immediately if available, then sync with backend
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

    // Responsive dimensions
    final horizontalPadding = screenWidth * 0.06;
    final topPadding = screenHeight * 0.025;
    final bottomPadding = screenHeight * 0.12;
    final headerFontSize = screenWidth * 0.07;
    final sectionSpacing = screenHeight * 0.04;
    final cardSpacing = screenHeight * 0.03;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                // Use syncWithBackend instead of fetchUserProfile for better feedback
                await profileProvider.syncWithBackend();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: topPadding,
                  bottom: bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/citations'),
                        icon: const Icon(Icons.info_outline),
                        label: Text(l10n.medicalReferences),
                      ),
                    ),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.profile,
                          style: TextStyle(
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        // Edit Profile Button
                        IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );

                            // Refresh profile if changes were made
                            if (result == true) {
                              profileProvider.fetchUserProfile();
                            }
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: screenWidth * 0.06,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.3),
                            padding: EdgeInsets.all(screenWidth * 0.03),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionSpacing),

                    // Profile Card
                    _buildProfileCard(l10n, userProfile),

                    SizedBox(height: cardSpacing * 0.5),

                    // Sync Status Indicator
                    //_buildSyncStatusIndicator(profileProvider),

                    SizedBox(height: cardSpacing),

                    // Membership Details Card
                    _buildMembershipCard(l10n, userProfile),

                    SizedBox(height: cardSpacing),

                    // Quick Actions
                    Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildActionCard(
                    //         'Goals',
                    //         Icons.flag_outlined,
                    //         Colors.blue,
                    //         () => _navigateToGoals(),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildActionCard(
                    //         'Progress',
                    //         Icons.trending_up_outlined,
                    //         Colors.purple,
                    //         () => _navigateToProgress(),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // const SizedBox(height: 16),

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildActionCard(
                    //         'Achievements',
                    //         Icons.emoji_events_outlined,
                    //         Colors.orange,
                    //         () => _navigateToAchievements(),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Expanded(
                    //       child: _buildActionCard(
                    //         'History',
                    //         Icons.history_outlined,
                    //         Colors.green,
                    //         () => _navigateToHistory(),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    //const SizedBox(height: 25),

                    // Settings Section
                    //_buildSettingsSection(),

                    //SizedBox(height: screenHeight * 0.02),

                    // Language Selection
                    _buildLanguageSelector(),
                    SizedBox(height: cardSpacing),

                    // Theme Selection
                    _buildThemeSelector(),
                    SizedBox(height: cardSpacing),

                    _buildDeleteAccountButton(),

                    SizedBox(height: cardSpacing),

                    // Logout Button
                    _buildLogoutButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withOpacity(0.3),
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
              label: Text(l10n.tryAgain,
                  style: TextStyle(fontSize: screenWidth * 0.04)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
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
              label: Text(l10n.refresh,
                  style: TextStyle(fontSize: screenWidth * 0.04)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AppLocalizations l10n, UserProfile userProfile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: screenWidth * 0.04,
            offset: Offset(0, screenWidth * 0.01),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture and Basic Info
          Row(
            children: [
              // Profile Picture
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.4),
                      blurRadius: screenWidth * 0.04,
                      offset: Offset(0, screenWidth * 0.02),
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

              SizedBox(width: screenWidth * 0.05),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      userProfile.phone,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        l10n.member,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // Weight and Height Row
          Row(
            children: [
              // Weight Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .tertiaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        userProfile.weight != null
                            ? '${userProfile.weight!.toStringAsFixed(1)} kg'
                            : l10n.notSet,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: userProfile.weight != null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        l10n.weight,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.04),

              // Height Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.height_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        userProfile.height != null
                            ? '${userProfile.height!.toStringAsFixed(0)} cm'
                            : l10n.notSet,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: userProfile.height != null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        l10n.height,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.025),

          // DOB and Gender Row
          Row(
            children: [
              // DOB Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        userProfile.birthday != null
                            ? '${userProfile.birthday!.day}/${userProfile.birthday!.month}/${userProfile.birthday!.year}'
                            : l10n.notSet,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: userProfile.birthday != null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.04),

              // Gender Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        userProfile.gender?.toLowerCase() == 'male' || userProfile.gender?.toLowerCase() == 'm'
                            ? Icons.male
                            : userProfile.gender?.toLowerCase() == 'female' || userProfile.gender?.toLowerCase() == 'f'
                                ? Icons.female
                                : Icons.person_outline,
                        color: Theme.of(context).colorScheme.secondary,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        userProfile.gender ?? l10n.notSet,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: userProfile.gender != null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BMI Display (if both weight and height are available)
          if (userProfile.weight != null && userProfile.height != null) ...[
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: screenWidth * 0.05,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        '${l10n.bmiLabel}: ${userProfile.bmi!.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    userProfile.bmiCategory!,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
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
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, screenWidth * 0.005),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.membershipDetails,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          if (userProfile.gymCode != null) ...[
            _buildInfoRow(l10n.clubCode, userProfile.gymCode!),
            SizedBox(height: screenHeight * 0.015),
          ],
          if (userProfile.joinDate != null) ...[
            _buildInfoRow(l10n.joinDate, _formatDate(userProfile.joinDate!)),
            SizedBox(height: screenHeight * 0.015),
          ],
          if (userProfile.membershipStartDate != null) ...[
            _buildInfoRow(
                l10n.startDate, _formatDate(userProfile.membershipStartDate!)),
            SizedBox(height: screenHeight * 0.015),
          ],
          if (userProfile.membershipEndDate != null) ...[
            _buildInfoRow(
                l10n.endDate, _formatDate(userProfile.membershipEndDate!)),
            SizedBox(height: screenHeight * 0.015),
          ],
          if (userProfile.membershipDuration != null) ...[
            _buildInfoRow(l10n.duration,
                l10n.months(userProfile.membershipDuration!)),
            SizedBox(height: screenHeight * 0.015),
          ],
          if (userProfile.membershipFees != null) ...[
            _buildInfoRow(l10n.fees,
                '₹${userProfile.membershipFees!.toStringAsFixed(0)}'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: screenWidth * 0.25,
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        //const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                'Notifications',
                Icons.notifications_outlined,
                isSwitch: true,
                switchValue: _notificationsEnabled,
                onSwitchChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                'Dark Mode',
                Icons.dark_mode_outlined,
                isSwitch: true,
                switchValue: _darkModeEnabled,
                onSwitchChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                'Biometric Login',
                Icons.fingerprint_outlined,
                isSwitch: true,
                switchValue: _biometricEnabled,
                onSwitchChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                'Privacy & Security',
                Icons.security_outlined,
                onTap: () => _navigateToPrivacy(),
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                'Data & Storage',
                Icons.storage_outlined,
                onTap: () => _navigateToDataStorage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                'Help & Support',
                Icons.help_outline,
                onTap: () => _navigateToHelp(),
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                'Rate App',
                Icons.star_outline,
                onTap: () => _rateApp(),
              ),
              _buildSettingsDivider(),
              _buildSettingsItem(
                'About',
                Icons.info_outline,
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: screenWidth * 0.025,
                offset: Offset(0, screenWidth * 0.005),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.language_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    l10n.language,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: localeProvider.locale.languageCode,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: [
                      DropdownMenuItem<String>(
                        value: 'en',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                l10n.english,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'hi',
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                l10n.hindi,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? newLanguageCode) async {
                      if (newLanguageCode != null) {
                        await localeProvider.setLocale(Locale(newLanguageCode));
                        // Snackbar removed - no longer showing language change messages
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSelector() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: screenWidth * 0.025,
                offset: Offset(0, screenWidth * 0.005),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    themeProvider.themeModeIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    l10n.theme,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: themeProvider.allThemeOptions(l10n).map((option) {
                      return DropdownMenuItem<ThemeMode>(
                        value: option.mode,
                        child: Row(
                          children: [
                            Icon(
                              option.icon,
                              color: Theme.of(context).colorScheme.primary,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    option.title,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    option.subtitle,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        themeProvider.setThemeMode(newMode);
                        // Snackbar removed - no longer showing theme change messages
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        onPressed: _isLoggingOut ? null : () => _showLogoutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
          foregroundColor: Theme.of(context).colorScheme.error,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            side: BorderSide(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
          ),
          disabledBackgroundColor:
              Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: _isLoggingOut
            ? SizedBox(
                width: screenWidth * 0.05,
                height: screenWidth * 0.05,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_outlined,
                      color: Theme.of(context).colorScheme.error,
                      size: screenWidth * 0.05),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    l10n.signOut,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.06,
      child: ElevatedButton(
        onPressed: () => _showDeleteAccountDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
          foregroundColor: Theme.of(context).colorScheme.error,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.04),
            side: BorderSide(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
                size: screenWidth * 0.05),
            SizedBox(width: screenWidth * 0.02),
            Text(
              l10n.deleteAccount,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get user initials
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // Helper method to build default avatar
  Widget _buildDefaultAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(_userProfile?.name ?? 'User'),
          style: TextStyle(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  // Helper method to build loading avatar
  Widget _buildLoadingAvatar(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Add reference to _userProfile for helper methods
  UserProfile? get _userProfile => context.read<ProfileProvider>().userProfile;

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon, {
    bool isSwitch = false,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.grey[600], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: Colors.green,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[100],
    );
  }

  void _showEditProfileDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.editProfile,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.profileEditingSoon,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok, style: TextStyle(color: Colors.green[600])),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          title: Text(
            l10n.signOut,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          content: Text(
            l10n.areYouSureSignOut,
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogout();
              },
              child: Text(
                l10n.signOut,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: screenWidth * 0.04,
                ),
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
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                l10n.deleteAccount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountConfirm,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importantInformation,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      l10n.deleteAccountInfo,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _launchDeleteAccountWebsite();
              },
              child: Text(
                l10n.continueToDelete,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Launch external website for account deletion
  Future<void> _launchDeleteAccountWebsite() async {
    final Uri deleteAccountUrl = Uri.parse(
        'https://mr-muscle-privacy-website.vercel.app/delete-account');

    try {
      if (await canLaunchUrl(deleteAccountUrl)) {
        await launchUrl(
          deleteAccountUrl,
          mode: LaunchMode.externalApplication,
        );

        // Show success message
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Redirected to account deletion page'),
          //     backgroundColor: Theme.of(context).colorScheme.primary,
          //     behavior: SnackBarBehavior.floating,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // );
        }
      } else {
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Unable to open the deletion page'),
          //     backgroundColor: Theme.of(context).colorScheme.error,
          //     behavior: SnackBarBehavior.floating,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // );
        }
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Error opening deletion page: $e'),
        //     backgroundColor: Theme.of(context).colorScheme.error,
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // );
      }
    }
  }

  // Show logout confirmation dialog
  // This method was removed as it was duplicated elsewhere

  // Proper logout implementation
  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Clear all authentication data using ProfileService
      await ProfileService.signOut();

      if (mounted) {
        // Snackbar removed - no longer showing logout success messages

        // Reset login provider state to phone input
        final loginProvider =
            Provider.of<LoginProvider>(context, listen: false);
        loginProvider.resetLoginState();

        // Navigate to login screen and clear entire navigation stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login', // Navigate to login screen
          (route) => false, // Remove all routes from the stack
        );
      }
    } catch (e) {
      // Even if sign out fails, still clear local data and navigate
      if (mounted) {
        // Snackbar removed - no longer showing error messages

        // Reset login provider state to phone input
        final loginProvider =
            Provider.of<LoginProvider>(context, listen: false);
        loginProvider.resetLoginState();

        // Still navigate to login screen
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

  void _showAboutDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          title: Text(
            'About FitTracker',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Your personal fitness companion for a healthier lifestyle.',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Navigation methods
  void _navigateToGoals() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _navigateToProgress() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _navigateToAchievements() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _navigateToHistory() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _navigateToPrivacy() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _navigateToDataStorage() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _navigateToHelp() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _rateApp() {
    // Snackbar removed - no longer showing coming soon messages
  }

  void _showThemeChangeSnackBar(String themeName) {
    // Snackbars removed - no longer showing theme change messages
  }

  void _showLanguageChangeSnackBar(String languageName) {
    // Snackbars removed - no longer showing language change messages
  }

  void _showComingSoonSnackBar(String feature) {
    // Snackbars removed - no longer showing coming soon messages
  }

  void _showSuccessSnackBar(String message) {
    // Snackbars removed - no longer showing success messages
  }

  void _showErrorSnackBar(String message) {
    // Snackbars removed - no longer showing error messages
  }

  Widget _buildSyncStatusIndicator(ProfileProvider profileProvider) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Choose appropriate icon and color based on sync status
    IconData icon;
    Color color;
    String statusText = profileProvider.syncStatus;

    if (profileProvider.isSyncing) {
      icon = Icons.sync;
      color = Theme.of(context).colorScheme.primary;
    } else if (!profileProvider.isOnline) {
      icon = Icons.cloud_off_outlined;
      color = Theme.of(context).colorScheme.outline;
    } else if (profileProvider.syncError != null) {
      icon = Icons.sync_problem_outlined;
      color = Theme.of(context).colorScheme.error;
    } else if (profileProvider.lastSyncTime != null) {
      icon = Icons.cloud_done_outlined;
      color = Theme.of(context).colorScheme.primary;
    } else {
      icon = Icons.sync_outlined;
      color = Theme.of(context).colorScheme.outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profileProvider.isSyncing)
            SizedBox(
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(
              icon,
              size: screenWidth * 0.04,
              color: color,
            ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            statusText,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (profileProvider.isDataStale && profileProvider.isOnline) ...[
            SizedBox(width: screenWidth * 0.02),
            GestureDetector(
              onTap: () => profileProvider.syncWithBackend(),
              child: Icon(
                Icons.refresh,
                size: screenWidth * 0.04,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
