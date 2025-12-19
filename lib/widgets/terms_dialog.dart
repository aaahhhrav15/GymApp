// lib/widgets/terms_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/terms_provider.dart';
import '../l10n/app_localizations.dart';

class TermsDialog extends StatefulWidget {
  final String title;
  final String context; // 'login'
  final VoidCallback? onAccepted;
  final VoidCallback? onDeclined;

  const TermsDialog({
    super.key,
    this.title = 'Terms and Conditions',
    this.context = 'login', // Default to login context
    this.onAccepted,
    this.onDeclined,
  });

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedEnd = false;
  bool _needsScrolling = false;
  double _contentHeight = 0;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Check content height after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkContentHeight();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkContentHeight() {
    if (_contentKey.currentContext != null) {
      final RenderBox renderBox =
          _contentKey.currentContext!.findRenderObject() as RenderBox;
      final contentHeight = renderBox.size.height;
      final screenHeight = MediaQuery.of(context).size.height;
      final maxContentHeight =
          screenHeight * 0.5; // Max 50% of screen for content

      setState(() {
        _contentHeight = contentHeight;
        _needsScrolling = contentHeight > maxContentHeight;
        // If content doesn't need scrolling, mark as reached end immediately
        if (!_needsScrolling) {
          _hasReachedEnd = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TermsProvider>().markScrolledToEnd();
          });
        }
      });
    }
  }

  void _scrollListener() {
    if (!_hasReachedEnd && _needsScrolling && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      // Consider "end" when user is within 50 pixels of the bottom
      if (currentScroll >= (maxScroll - 50)) {
        setState(() {
          _hasReachedEnd = true;
        });
        // Notify the provider that user has scrolled to end
        context.read<TermsProvider>().markScrolledToEnd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<TermsProvider>(
      builder: (context, termsProvider, child) {
        // Calculate responsive dialog dimensions
        final maxDialogHeight = mediaQuery.size.height * 0.8;
        final minDialogHeight = mediaQuery.size.height * 0.3;

        return Dialog(
          backgroundColor: theme.dialogBackgroundColor,
          insetPadding: EdgeInsets.symmetric(
            horizontal: mediaQuery.size.width * 0.05,
            vertical: mediaQuery.size.height * 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: mediaQuery.size.width * 0.9,
            constraints: BoxConstraints(
              minHeight: minDialogHeight,
              maxHeight: maxDialogHeight,
            ),
            padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      EdgeInsets.only(bottom: mediaQuery.size.height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.termsDialogTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _handleCancel(context),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface,
                          size: mediaQuery.size.width * 0.06,
                        ),
                        tooltip: l10n.close,
                      ),
                    ],
                  ),
                ),

                // Scroll indicator (only show if content needs scrolling)
                if (_needsScrolling && !_hasReachedEnd)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: mediaQuery.size.height * 0.01,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: mediaQuery.size.width * 0.04,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: mediaQuery.size.width * 0.02),
                        Expanded(
                          child: Text(
                            l10n.scrollToReadTerms,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Terms content
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: mediaQuery.size.height * 0.5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isDarkMode
                          ? theme.colorScheme.surface.withOpacity(0.1)
                          : theme.colorScheme.surface,
                    ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(mediaQuery.size.width * 0.04),
                      child: Text(
                        termsProvider.getTermsForContext(widget.context, l10n),
                        key: _contentKey,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),

                // Scroll progress indicator (only show if content needs scrolling)
                if (_needsScrolling)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: mediaQuery.size.height * 0.01,
                    ),
                    child: LinearProgressIndicator(
                      value: _scrollController.hasClients
                          ? (_scrollController.offset /
                                  (_scrollController.position.maxScrollExtent +
                                      1))
                              .clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor:
                          theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _hasReachedEnd
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),

                // Status text
                if (_hasReachedEnd)
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: mediaQuery.size.height * 0.01,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: mediaQuery.size.width * 0.04,
                        ),
                        SizedBox(width: mediaQuery.size.width * 0.02),
                        Text(
                          l10n.readCompleteTerms,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action buttons
                Container(
                  padding: EdgeInsets.only(top: mediaQuery.size.height * 0.02),
                  child: Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleCancel(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: mediaQuery.size.height * 0.015,
                            ),
                            side: BorderSide(color: theme.colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: mediaQuery.size.width * 0.04),

                      // Accept button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: termsProvider.canAccept && _hasReachedEnd
                              ? () => _handleAccept(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: mediaQuery.size.height * 0.015,
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            disabledBackgroundColor:
                                theme.colorScheme.outline.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: termsProvider.isLoading
                              ? SizedBox(
                                  height: mediaQuery.size.width * 0.04,
                                  width: mediaQuery.size.width * 0.04,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.accept,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: termsProvider.canAccept &&
                                            _hasReachedEnd
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.outline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAccept(BuildContext context) {
    final termsProvider = context.read<TermsProvider>();
    termsProvider.acceptTerms().then((_) {
      widget.onAccepted?.call();
      Navigator.of(context).pop(true);
    });
  }

  void _handleCancel(BuildContext context) {
    final termsProvider = context.read<TermsProvider>();
    termsProvider.declineTerms();
    widget.onDeclined?.call();
    Navigator.of(context).pop(false);
  }
}
