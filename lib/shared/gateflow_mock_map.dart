import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import 'gateflow_colors.dart';
import 'driver_route.dart';
import 'gateflow_location_picker.dart';

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

/// Compact map preview for address forms. Shows real map tiles; tap to open picker.
class GateFlowMiniLocationMap extends StatelessWidget {
  const GateFlowMiniLocationMap({
    super.key,
    required this.selectedLabel,
    required this.onUpdateLocation,
    this.hasLocation = false,
    this.latitude,
    this.longitude,
  });

  final String selectedLabel;
  final VoidCallback onUpdateLocation;
  final bool hasLocation;
  final double? latitude;
  final double? longitude;

  LatLng get _center {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return GateFlowLocationPicker.defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUpdateLocation,
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: hasLocation ? 15 : 12,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.gateflow.app',
                        ),
                        if (hasLocation && latitude != null && longitude != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(latitude!, longitude!),
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: GateFlowColors.brandPrimary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasLocation ? 'Location set' : 'Tap map to pick',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: GateFlowColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (!hasLocation)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app_rounded,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Open map',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
          selectedLabel.isEmpty
              ? 'Tap Update Location to pick on map'
              : selectedLabel,
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

/// Compact progress bar: milestone dots on a pill track (reference-style).
class GateFlowRouteLegBar extends StatelessWidget {
  const GateFlowRouteLegBar({super.key, required this.progress});

  final DriverRouteProgress progress;

  static const Color _trackFill = Color(0xFF6C63FF);
  static const Color _trackBg = Color(0xFFE8EAF0);

  @override
  Widget build(BuildContext context) {
    final eta = progress.estimatedMinutesRemaining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your progress',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: GateFlowColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.schedule_rounded,
                size: 14, color: GateFlowColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${eta}min',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: GateFlowColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _trackFill,
                  ),
                  children: [
                    TextSpan(text: '${progress.overallPercent}%'),
                    TextSpan(
                      text: ' to complete',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: GateFlowColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, 22),
              painter: _MilestoneTrackPainter(
                progress: progress.overallProgress.clamp(0.0, 1.0),
                stopCount: progress.routeStops.length.clamp(2, 8),
                fillColor: _trackFill,
                trackColor: _trackBg,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Current leg · ${progress.legSummary}',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: GateFlowColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MilestoneTrackPainter extends CustomPainter {
  _MilestoneTrackPainter({
    required this.progress,
    required this.stopCount,
    required this.fillColor,
    required this.trackColor,
  });

  final double progress;
  final int stopCount;
  final Color fillColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const barH = 14.0;
    final top = (size.height - barH) / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, size.width, barH),
      const Radius.circular(999),
    );

    canvas.drawRRect(rect, Paint()..color = trackColor);

    final fillW = size.width * progress;
    if (fillW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, top, fillW, barH),
          const Radius.circular(999),
        ),
        Paint()..color = fillColor,
      );
    }

    final dots = stopCount.clamp(2, 8);
    for (var i = 0; i < dots; i++) {
      final t = dots == 1 ? 0.0 : i / (dots - 1);
      final cx = size.width * t;
      final cy = top + barH / 2;
      final inside = t <= progress + 0.001;

      canvas.drawCircle(
        Offset(cx, cy),
        5,
        Paint()..color = inside ? Colors.white : fillColor,
      );
      if (!inside) {
        canvas.drawCircle(
          Offset(cx, cy),
          5,
          Paint()
            ..color = fillColor.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MilestoneTrackPainter old) =>
      old.progress != progress || old.stopCount != stopCount;
}

/// Vertical step timeline with student locations (order-tracking style).
class GateFlowRouteStepTimeline extends StatelessWidget {
  const GateFlowRouteStepTimeline({super.key, required this.progress});

  final DriverRouteProgress progress;

  static const Color _done = Color(0xFF22C55E);
  static const Color _pending = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final stops = progress.routeStops;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stops.length, (i) {
        final stop = stops[i];
        final done = stop.phase == RouteStopPhase.completed;
        final active = stop.phase == RouteStopPhase.active;
        final dotColor = done || active ? _done : _pending;
        final lineColor =
            i < stops.length - 1 && done ? _done : _pending.withValues(alpha: 0.45);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    _StepDot(color: dotColor, active: active),
                    if (i < stops.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: lineColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: i < stops.length - 1 ? 22 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: GateFlowColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: GateFlowColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              stop.location,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: GateFlowColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stop.detail,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: active
                              ? GateFlowColors.brandPrimary
                              : GateFlowColors.textTertiary,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Multi-stop route map for driver detail (A→B→C→D…).
class GateFlowDriverRouteMap extends StatelessWidget {
  const GateFlowDriverRouteMap({
    super.key,
    required this.progress,
    this.height = 200,
  });

  final DriverRouteProgress progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _MultiStopRoutePainter(progress: progress),
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
                ),
                child: Text(
                  progress.legSummary,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiStopRoutePainter extends CustomPainter {
  _MultiStopRoutePainter({required this.progress});

  final DriverRouteProgress progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stops = progress.stops;
    if (stops.length < 2) return;

    final bg = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFE3F2FD),
          GateFlowColors.brandPrimary.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < stops.length; i++) {
      final t = i / (stops.length - 1);
      points.add(Offset(
        size.width * (0.1 + 0.8 * t),
        size.height * (0.75 - 0.55 * t),
      ));
    }
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final cur = points[i];
      path.quadraticBezierTo(
        (prev.dx + cur.dx) / 2,
        (prev.dy + cur.dy) / 2 - 12,
        cur.dx,
        cur.dy,
      );
    }

    final track = Paint()
      ..color = GateFlowColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, track);

    final metrics = path.computeMetrics().first;
    final overall = progress.overallProgress.clamp(0.0, 1.0);
    final active = metrics.extractPath(0, metrics.length * overall);
    canvas.drawPath(
      active,
      Paint()
        ..color = GateFlowColors.brandAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < points.length; i++) {
      final done = progress.isStopCompleted(i);
      final current = progress.isStopCurrent(i);
      final fill = done
          ? GateFlowColors.success
          : current
              ? GateFlowColors.brandAccent
              : Colors.white;
      canvas.drawCircle(points[i], 9, Paint()..color = fill);
      canvas.drawCircle(
        points[i],
        9,
        Paint()
          ..color = GateFlowColors.brandPrimary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final busPos = metrics.getTangentForOffset(metrics.length * overall)?.position ??
        points.first;
    final busR = Rect.fromCenter(center: busPos, width: 24, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(busR, const Radius.circular(5)),
      Paint()..color = GateFlowColors.brandPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _MultiStopRoutePainter old) =>
      old.progress.overallProgress != progress.overallProgress ||
      old.progress.currentLegIndex != progress.currentLegIndex;
}
