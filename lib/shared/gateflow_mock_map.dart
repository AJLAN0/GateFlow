import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gateflow_colors.dart';

/// Mock route map: path from start → end with bus marker along progress [0–1].
/// No external map SDK or API keys.
class GateFlowMockRouteMap extends StatelessWidget {
  const GateFlowMockRouteMap({
    super.key,
    required this.progress,
    this.height = 168,
    this.routeLabel,
  });

  final double progress;
  final double height;
  final String? routeLabel;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(
              painter: _RouteMapPainter(
                progress: progress.clamp(0.0, 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_bus_rounded,
                            size: 16, color: GateFlowColors.brandPrimary),
                        const SizedBox(width: 6),
                        Text(
                          '$pct% along route',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: GateFlowColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (routeLabel != null) ...[
          const SizedBox(height: 8),
          Text(
            routeLabel!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GateFlowColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  _RouteMapPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFE8F5E9),
          GateFlowColors.brandPrimary.withValues(alpha: 0.12),
          const Color(0xFFFFF8E1),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(18),
      ),
      bg,
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path();
    final start = Offset(size.width * 0.12, size.height * 0.72);
    final mid = Offset(size.width * 0.48, size.height * 0.38);
    final end = Offset(size.width * 0.88, size.height * 0.18);
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(mid.dx, mid.dy + 20, end.dx, end.dy);

    final track = Paint()
      ..color = GateFlowColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, track);

    final progLen = progress.clamp(0.0, 1.0);
    final dashPaint = Paint()
      ..shader = LinearGradient(
        colors: [GateFlowColors.brandPrimary, GateFlowColors.brandAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final metrics = path.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * progLen);
    canvas.drawPath(extract, dashPaint);

    void drawStop(Offset o, Color fill, String label) {
      canvas.drawCircle(o, 10, Paint() ..color = Colors.white);
      canvas.drawCircle(o, 8, Paint() ..color = fill);
    }

    drawStop(start, GateFlowColors.success, 'A');
    drawStop(end, GateFlowColors.danger, 'B');

    final busPos = metrics.getTangentForOffset(metrics.length * progLen)?.position ??
        Offset.lerp(start, end, progLen)!;
    final busR = Rect.fromCenter(center: busPos, width: 26, height: 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(busR, const Radius.circular(6)),
      Paint() ..color = GateFlowColors.brandAccent,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(busR, const Radius.circular(6)),
      Paint()
        ..color = GateFlowColors.brandPrimary.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Compact “pick on map” preview for schedules / address forms (mock).
class GateFlowMiniLocationMap extends StatelessWidget {
  const GateFlowMiniLocationMap({
    super.key,
    required this.selectedLabel,
    required this.onUpdateLocation,
  });

  final String selectedLabel;
  final VoidCallback onUpdateLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GateFlowColors.surface,
                        GateFlowColors.brandPrimary.withValues(alpha: 0.07),
                      ],
                    ),
                  ),
                ),
                CustomPaint(painter: _MiniGridPainter()),
                Center(
                  child: Icon(Icons.location_pin,
                      size: 44, color: GateFlowColors.brandPrimary),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Mock map',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Selected location',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: GateFlowColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          selectedLabel.isEmpty ? 'Tap update to assign a mock pin' : selectedLabel,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: GateFlowColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onUpdateLocation,
            icon: const Icon(Icons.edit_location_alt_rounded, size: 20),
            label: const Text('Update Location'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GateFlowColors.brandPrimary,
              side: const BorderSide(color: GateFlowColors.divider),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = GateFlowColors.divider.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final ring = Paint()
      ..color = GateFlowColors.brandAccent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.48),
      math.min(size.width, size.height) * 0.22,
      ring,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
