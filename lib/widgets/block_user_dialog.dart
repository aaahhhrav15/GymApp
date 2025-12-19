import 'package:flutter/material.dart';
import '../services/moderation_service.dart';

class BlockUserDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const BlockUserDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _blockReasons = [
    {'value': 'harassment', 'label': 'Harassment or Bullying'},
    {'value': 'inappropriate', 'label': 'Inappropriate Content'},
    {'value': 'spam', 'label': 'Spam or Misleading'},
    {'value': 'hate_speech', 'label': 'Hate Speech'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.block,
            color: Colors.red,
            size: screenWidth * 0.06,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              'Block User',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you blocking ${widget.userName}?',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            
            // Reason selection
            ..._blockReasons.map((reason) => RadioListTile<String>(
              value: reason['value']!,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              title: Text(
                reason['label']!,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            )),
            
            SizedBox(height: screenWidth * 0.04),
            
            // Additional details
            Text(
              'Additional Details (Optional)',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Provide more details about the issue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(screenWidth * 0.03),
              ),
            ),
            
            SizedBox(height: screenWidth * 0.04),
            
            // Info text
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.red,
                    size: screenWidth * 0.04,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      'Blocked users will not be able to interact with you or see your content.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedReason == null
              ? null
              : _blockUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: screenWidth * 0.04,
                  height: screenWidth * 0.04,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Block User'),
        ),
      ],
    );
  }

  Future<void> _blockUser() async {
    if (_selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ModerationService.blockUser(
        userId: widget.userId,
        reason: _selectedReason!,
      );

      if (mounted) {
        Navigator.pop(context);
        
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       result['success']
        //           ? 'User blocked successfully'
        //           : 'Failed to block user. Please try again.',
        //     ),
        //     backgroundColor: result['success'] ? Colors.green : Colors.red,
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Failed to block user. Please try again.'),
        //     backgroundColor: Colors.red,
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
