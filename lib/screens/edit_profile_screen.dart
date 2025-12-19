import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/profile_provider.dart';
import '../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      _nameController.text = provider.editName;
      _phoneController.text = provider.editPhone;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => _handleBackButton(),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.isUpdating ? null : _saveProfile,
                child: provider.isUpdating
                    ? SizedBox(
                        width: screenWidth * 0.05,
                        height: screenWidth * 0.05,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.save,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final padding = screenWidth * 0.04;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                _buildProfileImageSection(provider),
                SizedBox(height: screenWidth * 0.06),

                // Editable Fields Section
                _buildEditableFieldsSection(provider),
                SizedBox(height: screenWidth * 0.06),

                // Non-Editable Fields Section (Read-only)
                _buildReadOnlyFieldsSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection(ProfileProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.03;
    final padding = screenWidth * 0.05;
    final imageSize = screenWidth * 0.3;
    final spacing = screenWidth * 0.04;
    final buttonPadding = screenWidth * 0.04;

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.profilePicture,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: padding),

            // Profile Image Display
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _buildProfileImage(provider),
              ),
            ),
            SizedBox(height: spacing),

            // Image Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera Button
                ElevatedButton.icon(
                  onPressed: provider.pickProfileImageFromCamera,
                  icon: Icon(Icons.camera_alt, size: screenWidth * 0.05),
                  label: Text(AppLocalizations.of(context)!.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPadding,
                      vertical: buttonPadding * 0.5,
                    ),
                  ),
                ),

                // Gallery Button
                ElevatedButton.icon(
                  onPressed: provider.pickProfileImageFromGallery,
                  icon: Icon(Icons.photo_library, size: screenWidth * 0.05),
                  label: Text(AppLocalizations.of(context)!.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonPadding,
                      vertical: buttonPadding * 0.5,
                    ),
                  ),
                ),

                // Remove Button (if image is selected)
                if (provider.selectedProfileImage != null)
                  ElevatedButton.icon(
                    onPressed: provider.removeSelectedProfileImage,
                    icon: Icon(Icons.delete, size: screenWidth * 0.05),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonPadding,
                        vertical: buttonPadding * 0.5,
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

  Widget _buildProfileImage(ProfileProvider provider) {
    // Show selected image first
    if (provider.selectedProfileImage != null) {
      return Image.file(
        File(provider.selectedProfileImage!.path),
        fit: BoxFit.cover,
      );
    }

    // Show current profile image
    if (provider.userProfile?.profileImageUrl != null) {
      return Image.network(
        provider.userProfile!.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }

    // Show default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.person,
        size: screenWidth * 0.15,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEditableFieldsSection(ProfileProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.03;
    final padding = screenWidth * 0.05;
    final spacing = screenWidth * 0.04;
    final iconSize = screenWidth * 0.05;

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: iconSize,
                ),
                SizedBox(width: spacing * 0.5),
                Text(
                  AppLocalizations.of(context)!.editableInformation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: padding),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: AppLocalizations.of(context)!.name,
              icon: Icons.person_outline,
              onChanged: provider.updateEditName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.nameIsRequired;
                }
                return null;
              },
            ),
            SizedBox(height: spacing),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: AppLocalizations.of(context)!.phoneNumber,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: provider.updateEditPhone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.phoneNumberIsRequired;
                }
                return null;
              },
            ),
            SizedBox(height: spacing),

            // Date of Birth Field
            _buildDateOfBirthField(provider),
            SizedBox(height: spacing),

            // Gender Field
            _buildGenderField(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyFieldsSection(ProfileProvider provider) {
    final userProfile = provider.userProfile;
    if (userProfile == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.03;
    final padding = screenWidth * 0.05;
    final spacing = screenWidth * 0.04;
    final iconSize = screenWidth * 0.05;

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.outline,
                  size: iconSize,
                ),
                SizedBox(width: spacing * 0.5),
                Text(
                  AppLocalizations.of(context)!.readOnlyInformation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: padding),
            _buildReadOnlyField(AppLocalizations.of(context)!.clubCode,
                userProfile.gymCode ?? 'N/A', Icons.business_outlined),
            _buildReadOnlyField(
                AppLocalizations.of(context)!.joinDate,
                userProfile.joinDate != null
                    ? _formatDate(userProfile.joinDate!)
                    : 'N/A',
                Icons.date_range_outlined),
            _buildReadOnlyField(
                AppLocalizations.of(context)!.membershipDuration,
                userProfile.membershipDuration != null
                    ? AppLocalizations.of(context)!
                        .months(userProfile.membershipDuration!)
                    : 'N/A',
                Icons.timer_outlined),
            _buildReadOnlyField(
                AppLocalizations.of(context)!.membershipFees,
                userProfile.membershipFees != null
                    ? '₹${userProfile.membershipFees!.toStringAsFixed(0)}'
                    : 'N/A',
                Icons.payment_outlined),
            
            // Weight, Height, and Age (read-only - edited in Body Composition)
            if (userProfile.weight != null)
              _buildReadOnlyField(
                  AppLocalizations.of(context)!.weight,
                  '${userProfile.weight!.toStringAsFixed(1)} kg',
                  Icons.monitor_weight_outlined),
            if (userProfile.height != null)
              _buildReadOnlyField(
                  AppLocalizations.of(context)!.height,
                  '${userProfile.height!.toStringAsFixed(0)} cm',
                  Icons.height_outlined),
            if (userProfile.birthday != null)
              _buildReadOnlyField(
                  'Age',
                  '${_calculateAge(userProfile.birthday!)} years',
                  Icons.cake_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.02;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: screenWidth * 0.05,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.02;
    final iconSize = screenWidth * 0.05;
    final spacing = screenWidth * 0.03;
    final labelFontSize = screenWidth * 0.03;
    final valueFontSize = screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding * 0.5),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(borderRadius),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: iconSize,
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: labelFontSize,
                        ),
                  ),
                  SizedBox(height: padding * 0.25),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: valueFontSize,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  Widget _buildDateOfBirthField(ProfileProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.02;

    return InkWell(
      onTap: () async {
        // Ensure initial date is normalized (already normalized in provider, but ensure it's a valid date)
        final initialDate = provider.editBirthday ?? DateTime(1990, 1, 1);
        final firstDate = DateTime(1900, 1, 1);
        final lastDate = DateTime.now();

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        if (pickedDate != null) {
          // showDatePicker returns a date at local midnight, normalize it to ensure consistency
          provider.updateEditBirthday(pickedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.04),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(borderRadius),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: screenWidth * 0.05,
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    provider.editBirthday != null
                        ? _formatDate(provider.editBirthday!)
                        : 'Select date of birth',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: provider.editBirthday != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField(ProfileProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.02;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(borderRadius),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
                size: screenWidth * 0.05,
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  'Male',
                  Icons.male,
                  provider.editGender == 'Male' || provider.editGender == 'male' || provider.editGender == 'M' || provider.editGender == 'm',
                  () => provider.updateEditGender('Male'),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: _buildGenderOption(
                  'Female',
                  Icons.female,
                  provider.editGender == 'Female' || provider.editGender == 'female' || provider.editGender == 'F' || provider.editGender == 'f',
                  () => provider.updateEditGender('Female'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = screenWidth * 0.02;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: screenWidth * 0.05,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBackButton() {
    final provider = context.read<ProfileProvider>();

    if (provider.hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showUnsavedChangesDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.unsavedChanges),
          content: Text(l10n.unsavedChangesMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.read<ProfileProvider>().resetEditForm();
                Navigator.pop(context); // Close edit screen
              },
              child: Text(
                l10n.discard,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() async {
    final provider = context.read<ProfileProvider>();
    final l10n = AppLocalizations.of(context)!;

    // Validate name and phone fields
    if (provider.editName.trim().isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(l10n.nameIsRequired),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
      return;
    }

    if (provider.editPhone.trim().isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(l10n.phoneNumberIsRequired),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
      return;
    }

    final result = await provider.updateProfile();

    if (result['success']) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(result['message'] ?? l10n.profileUpdatedSuccessfully),
      //     backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      //   ),
      // );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(result['error'] ?? l10n.failedToUpdateProfile),
      //     backgroundColor: Theme.of(context).colorScheme.error,
      //   ),
      // );
    }
  }
}
