import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dimensions
    final appBarIconPadding = screenWidth * 0.02;
    final appBarIconSize = screenWidth * 0.05;
    final appBarTitleFontSize = screenWidth * 0.05;
    final borderRadius = screenWidth * 0.03;
    final bodyPadding = screenWidth * 0.06;
    final headerPadding = screenWidth * 0.08;
    final sectionSpacing = screenHeight * 0.025;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () => Navigator.pop(context),
        //   icon: Container(
        //     padding: EdgeInsets.all(appBarIconPadding),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(borderRadius),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.1),
        //           blurRadius: 10,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: Icon(
        //       Icons.arrow_back_ios_new,
        //       color: Colors.black87,
        //       size: appBarIconSize,
        //     ),
        //   ),
        // ),
        title: Text(
          'Register',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineLarge?.color,
            fontSize: appBarTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(bodyPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: sectionSpacing),

            // Contact Us Header
            Container(
              padding: EdgeInsets.all(headerPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius * 2),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(screenWidth * 0.125),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: screenWidth * 0.1,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'We\'re here to help you on your fitness journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.7),
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: sectionSpacing * 1.25),

            // Registration Notice
            Container(
              padding: EdgeInsets.all(bodyPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(borderRadius * 1.25),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(borderRadius),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(screenWidth * 0.125),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Registration Coming Soon!',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'We\'re working on building an amazing registration experience. For now, please contact us directly for any assistance or questions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Methods
            _buildContactMethod(
              context,
              icon: Icons.email_rounded,
              title: 'Email Us',
              subtitle: 'team@meeraaitech.com',
              color: const Color(0xFFFF6B6B),
              onTap: () => _launchEmail('team@meeraaitech.com'),
            ),

            const SizedBox(height: 16),

            _buildContactMethod(
              context,
              icon: Icons.phone_rounded,
              title: 'Call Us',
              subtitle: '+91 97988 93573',
              color: const Color(0xFF4ECDC4),
              onTap: () => _launchPhone('+91 97988 93573'),
            ),

            const SizedBox(height: 16),

            // _buildContactMethod(
            //   icon: Icons.chat_bubble_outline_rounded,
            //   title: 'Live Chat',
            //   subtitle: 'Available 24/7',
            //   color: const Color(0xFF45B7D1),
            //   onTap: () => _showLiveChatInfo(context),
            // ),

            const SizedBox(height: 32),

            // Social Media
            // Container(
            //   padding: const EdgeInsets.all(24),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(20),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         blurRadius: 10,
            //         offset: const Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     children: [
            //       const Text(
            //         'Follow Us',
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.black87,
            //         ),
            //       ),
            //       const SizedBox(height: 16),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           _buildSocialButton(
            //             icon: Icons.facebook,
            //             color: const Color(0xFF3B5998),
            //             onTap: () => _launchURL('https://facebook.com'),
            //           ),
            //           _buildSocialButton(
            //             icon: Icons.camera_alt,
            //             color: const Color(0xFFE4405F),
            //             onTap: () => _launchURL('https://instagram.com'),
            //           ),
            //           _buildSocialButton(
            //             icon: Icons.alternate_email,
            //             color: const Color(0xFF1DA1F2),
            //             onTap: () => _launchURL('https://twitter.com'),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 32),

            // Footer
            Text(
              'Thank you for choosing Mr Muscle!\nWe appreciate your patience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    try {
      await Clipboard.setData(ClipboardData(text: email));
      _showCopyMessage('Email address copied to clipboard!');
    } catch (e) {
      _showCopyMessage('Could not copy email address');
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    // Format phone number for display
    final displayNumber = '+91 97988 93573';
    try {
      await Clipboard.setData(ClipboardData(text: displayNumber));
      _showCopyMessage('Phone number copied to clipboard!');
    } catch (e) {
      _showCopyMessage('Could not copy phone number');
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));
      _showCopyMessage('URL copied to clipboard!');
    } catch (e) {
      _showCopyMessage('Could not copy URL');
    }
  }

  void _showCopyMessage(String message) {
    // This would show a snackbar if we have access to ScaffoldMessenger
    // For now, we'll just print to console
    debugPrint(message);
  }

  void _showLiveChatInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF45B7D1),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Live Chat Coming Soon!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We\'re working on integrating live chat support. For now, please use email or phone for immediate assistance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF45B7D1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
