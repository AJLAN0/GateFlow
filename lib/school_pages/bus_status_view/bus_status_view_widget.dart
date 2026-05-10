import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/status_pill.dart';
import 'bus_status_view_model.dart';

export 'bus_status_view_model.dart';

/// School-side operational snapshot for a focal bus route (mock data).
class BusStatusViewWidget extends StatefulWidget {
  const BusStatusViewWidget({super.key});

  static String routeName = 'BusStatusView';
  static String routePath = '/busStatusView';

  @override
  State<BusStatusViewWidget> createState() => _BusStatusViewWidgetState();
}

class _BusStatusViewWidgetState extends State<BusStatusViewWidget> {
  late BusStatusViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _busStatusPhrase(BusStatus s) {
    switch (s) {
      case BusStatus.stationary:
        return 'Stationary · Idle at depot';
      case BusStatus.onRouteToSchool:
        return 'Driving to campus';
      case BusStatus.onRouteToHome:
        return 'Driving home dismissal';
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusStatusViewModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final bus = mock.buses.isNotEmpty ? mock.buses.first : null;
    final assigned = mock.students.where((s) => s.busId == bus?.id).toList();
    final onBus = assigned
        .where((s) =>
            s.status == StudentStatus.onBusToHome ||
            s.status == StudentStatus.onBusToSchool)
        .length;
    final dropped = assigned.where((s) => s.status == StudentStatus.atHome).length;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            buttonSize: 56,
            icon:
                const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            bus == null ? 'Bus status' : bus.name,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: bus == null
              ? Center(
                  child: Text(
                    'No bus data seeded.',
                    style: GoogleFonts.inter(color: GateFlowColors.textSecondary),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: GateFlowColors.divider),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: GateFlowColors.brandPrimary
                                      .withValues(alpha: .12),
                                  child: Icon(Icons.directions_bus_rounded,
                                      color: GateFlowColors.brandPrimary, size: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bus.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        bus.routeLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: GateFlowColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        'Driver · ${bus.driverName}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: GateFlowColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusPill(
                                  label: _busStatusPhrase(bus.status),
                                  tone: StatusTone.pending,
                                  icon: Icons.departure_board_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              bus.lastUpdateLabel ??
                                  'Last update synced (mock)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: GateFlowColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Route preview',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: GateFlowColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GateFlowColors.divider),
                          gradient: LinearGradient(
                            colors: [
                              GateFlowColors.surface,
                              GateFlowColors.brandPrimary.withValues(alpha: .05),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Static corridor map · ${bus.routeLabel}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: GateFlowColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'On bus',
                              value: onBus.toString(),
                              icon: Icons.airline_seat_recline_normal_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              label: 'Dropped off',
                              value: dropped.toString(),
                              icon: Icons.task_alt_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              label: 'Assigned',
                              value: assigned.length.toString(),
                              icon: Icons.groups_2_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Students on this bus',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: GateFlowColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (assigned.isEmpty)
                        Text(
                          'No riders linked in mock data.',
                          style: GoogleFonts.inter(
                              color: GateFlowColors.textTertiary),
                        )
                      else
                        ...assigned.take(4).map(
                              (s) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: GateFlowColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.name,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            '${s.grade} · ${s.lastMockUpdateLabel}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: GateFlowColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      if (assigned.length > 4)
                        Text(
                          '+ ${assigned.length - 4} more students',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: GateFlowColors.textTertiary,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Operational alerts',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: GateFlowColors.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (mock.operationalAlerts.isEmpty)
                        Text(
                          'No active alerts.',
                          style: GoogleFonts.inter(
                              color: GateFlowColors.textTertiary),
                        ),
                      ...mock.operationalAlerts.take(3).map(
                            (a) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8EC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      GateFlowColors.warning.withValues(alpha: .4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.body,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      height: 1.3,
                                      color: GateFlowColors.textSecondary,
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
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: GateFlowColors.brandPrimary,
              size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: GateFlowColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
