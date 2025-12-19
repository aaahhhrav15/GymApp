import 'package:flutter/material.dart';
import '../services/moderation_service.dart';

class ReportDialog extends StatefulWidget {
  final String contentType; // 'reel', 'accountability', 'result'
  final String contentId;
  final String contentTitle;

  const ReportDialog({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _reportReasons = [
    {'value': 'inappropriate', 'label': 'Inappropriate Content'},
    {'value': 'harassment', 'label': 'Harassment or Bullying'},
    {'value': 'spam', 'label': 'Spam or Misleading'},
    {'value': 'violence', 'label': 'Violence or Dangerous Acts'},
    {'value': 'nudity', 'label': 'Nudity or Sexual Content'},
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
            Icons.flag_outlined,
            color: Colors.red,
            size: screenWidth * 0.06,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              'Report Content',
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
              'Why are you reporting this ${widget.contentType}?',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            
            // Reason selection
            ..._reportReasons.map((reason) => RadioListTile<String>(
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
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: screenWidth * 0.04,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Text(
                      'We review all reports within 24 hours and take appropriate action.',
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
              : _submitReport,
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
              : Text('Report'),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ModerationService.reportContent(
        contentType: widget.contentType,
        contentId: widget.contentId,
        reason: _selectedReason!,
        additionalDetails: _detailsController.text.trim().isNotEmpty
            ? _detailsController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       result['success']
        //           ? result['message']
        //           : 'Failed to report content. Please try again.',
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
        //     content: Text('Failed to report content. Please try again.'),
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
