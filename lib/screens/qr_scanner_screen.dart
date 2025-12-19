import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/attendance_service.dart';
import '../l10n/app_localizations.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _handled = false;
  MobileScannerController controller = MobileScannerController();

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final uri = Uri.tryParse(raw);
    String? gymCode;
    if (uri != null) {
      final segments = uri.pathSegments;
      final idx = segments.indexOf('mark_attendance');
      if (idx != -1 && idx + 1 < segments.length) {
        gymCode = segments[idx + 1];
      }
    }
    gymCode ??= raw;

    _handled = true;
    await controller.stop();
    final result = await AttendanceService.markAttendance(gymCode);
    if (!mounted) return;
    // Snackbar removed - no longer showing attendance status messages
    Navigator.of(context).pop(result['success'] == true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQr),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Scanner View
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Overlay with scanning frame
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 12,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: screenWidth * 0.7,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context)!.pointCameraAtQr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom overlay shape for the scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.borderLength = 40,
    this.borderRadius = 0,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderOffset = borderWidth / 2;
    final actualBorderLength = borderLength > width / 2 + borderOffset
        ? width / 2 + borderOffset
        : borderLength;
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    ).deflate(borderOffset);

    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right - borderRadius, rect.top);
    }

    Path getRightTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left + actualBorderLength, rect.top)
        ..lineTo(rect.right - borderRadius, rect.top)
        ..quadraticBezierTo(
            rect.right, rect.top, rect.right, rect.top + borderRadius)
        ..lineTo(rect.right, rect.bottom);
    }

    Path getRightBottomPath(Rect rect) {
      return Path()
        ..moveTo(rect.right, rect.top + actualBorderLength)
        ..lineTo(rect.right, rect.bottom - borderRadius)
        ..quadraticBezierTo(
            rect.right, rect.bottom, rect.right - borderRadius, rect.bottom)
        ..lineTo(rect.left + borderRadius, rect.bottom);
    }

    Path getLeftBottomPath(Rect rect) {
      return Path()
        ..moveTo(rect.right - actualBorderLength, rect.bottom)
        ..lineTo(rect.left + borderRadius, rect.bottom)
        ..quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius)
        ..lineTo(rect.left, rect.top);
    }

    if (borderRadius > actualBorderLength) {
      return Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            cutOutRect,
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
        );
    }

    return Path()
      ..addPath(
          getLeftTopPath(Rect.fromLTRB(
              cutOutRect.left,
              cutOutRect.top,
              cutOutRect.left + actualBorderLength,
              cutOutRect.top + actualBorderLength)),
          Offset.zero)
      ..addPath(
          getRightTopPath(Rect.fromLTRB(
              cutOutRect.right - actualBorderLength,
              cutOutRect.top,
              cutOutRect.right,
              cutOutRect.top + actualBorderLength)),
          Offset.zero)
      ..addPath(
          getRightBottomPath(Rect.fromLTRB(
              cutOutRect.right - actualBorderLength,
              cutOutRect.bottom - actualBorderLength,
              cutOutRect.right,
              cutOutRect.bottom)),
          Offset.zero)
      ..addPath(
          getLeftBottomPath(Rect.fromLTRB(
              cutOutRect.left,
              cutOutRect.bottom - actualBorderLength,
              cutOutRect.left + actualBorderLength,
              cutOutRect.bottom)),
          Offset.zero);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderOffset = borderWidth / 2;
    final actualBorderLength = borderLength > width / 2 + borderOffset
        ? width / 2 + borderOffset
        : borderLength;
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    ).deflate(borderOffset);

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (borderRadius > actualBorderLength) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        paint,
      );
      return;
    }

    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}
