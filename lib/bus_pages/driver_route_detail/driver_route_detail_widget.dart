import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/driver_route.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/gateflow_mock_map.dart';
import 'driver_route_detail_model.dart';

export 'driver_route_detail_model.dart';

/// Driver-only live route: milestone progress + vertical stop timeline.
/// Distinct from the school admin [BusStatusViewWidget].
class DriverRouteDetailWidget extends StatefulWidget {
  const DriverRouteDetailWidget({super.key});

  static String routeName = 'DriverRouteDetail';
  static String routePath = '/driverRouteDetail';

  @override
  State<DriverRouteDetailWidget> createState() =>
      _DriverRouteDetailWidgetState();
}

class _DriverRouteDetailWidgetState extends State<DriverRouteDetailWidget> {
  late DriverRouteDetailModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverRouteDetailModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    mock.resolveDriverBusContext();
    final bus = mock.currentDriverBus;
    final riders = mock.studentsOnDriverBus;
    final route = computeDriverRouteProgress(bus: bus, riders: riders);

    return Scaffold(
      backgroundColor: GateFlowColors.surface,
      appBar: AppBar(
        backgroundColor: GateFlowColors.brandPrimary,
        leading: FlutterFlowIconButton(
          borderRadius: 30,
          buttonSize: 56,
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 26),
          onPressed: () => context.safePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My route',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              bus?.name ?? 'Your bus',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GateFlowColors.divider),
            ),
            child: GateFlowRouteLegBar(progress: route),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.people_alt_outlined,
            title: 'Drop-offs today',
            body:
                '${route.completedDropoffs} of ${route.totalRiders} riders delivered',
            trailing: '${route.overallPercent}%',
          ),
          const SizedBox(height: 20),
          Text(
            'Route stops',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Each point shows the student drop-off location',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: GateFlowColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GateFlowColors.divider),
            ),
            child: GateFlowRouteStepTimeline(progress: route),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String body;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: GateFlowColors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: GateFlowColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(body,
                    style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: GateFlowColors.textPrimary)),
              ],
            ),
          ),
          Text(trailing,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: GateFlowColors.brandPrimary)),
        ],
      ),
    );
  }
}
