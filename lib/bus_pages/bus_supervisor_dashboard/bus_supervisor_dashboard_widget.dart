import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import 'bus_supervisor_dashboard_model.dart';

export 'bus_supervisor_dashboard_model.dart';

/// Bus driver / supervisor dashboard.
///
/// Modernized layout: gradient hero with greeting and bus assignment,
/// trip stats, trip progress card, primary CTA "View Student List", and
/// quick access tiles for boarding, notifications, profile.
class BusSupervisorDashboardWidget extends StatefulWidget {
  const BusSupervisorDashboardWidget({super.key});

  static String routeName = 'BusSupervisorDashboard';
  static String routePath = '/busSupervisorDashboard';

  @override
  State<BusSupervisorDashboardWidget> createState() =>
      _BusSupervisorDashboardWidgetState();
}

class _BusSupervisorDashboardWidgetState
    extends State<BusSupervisorDashboardWidget> {
  late BusSupervisorDashboardModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BusSupervisorDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockState = context.watch<MockState>();
    final bus =
        mockState.buses.isNotEmpty ? mockState.buses.first : null;
    final busTitle = bus == null
        ? 'GateFlow Bus'
        : '${bus.name} · ${bus.routeLabel}';

    final onBus = mockState.students
        .where((s) =>
            s.status == StudentStatus.onBusToHome ||
            s.status == StudentStatus.onBusToSchool)
        .length;
    final droppedOff = mockState.students
        .where((s) =>
            s.status == StudentStatus.atHome ||
            s.status == StudentStatus.pickedUpByCar)
        .length;
    final total = mockState.students.length;
    final progress = total == 0 ? 0.0 : droppedOff / total;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        bottomNavigationBar: const RoleBottomNav(current: 'home'),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              const SizedBox(height: 8),
              _BusHeader(
                busLabel: busTitle,
                driverName: bus?.driverName ?? 'Driver',
              ),
              const SizedBox(height: 18),
              _BusStatsRow(total: total, onBus: onBus, dropped: droppedOff),
              const SizedBox(height: 16),
              _RoutePreviewCard(bus: bus, completionPct: progress),
              const SizedBox(height: 14),
              _DriverPrimaryActions(),
              const SizedBox(height: 22),
              const _BusSectionTitle(title: 'Operational shortcuts'),
              const SizedBox(height: 10),
              _BusQuickActions(),
            ],
          ).animate().fade(duration: 500.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }
}

class _BusHeader extends StatelessWidget {
  const _BusHeader({required this.busLabel, required this.driverName});

  final String busLabel;
  final String driverName;

  @override
  Widget build(BuildContext context) {
    final greetingName =
        driverName.contains('You') ? 'Driver' : driverName.split(' ').first;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GateFlowColors.brandPrimary,
            GateFlowColors.brandPrimarySoft,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GateFlowColors.brandPrimary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On Duty',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hello, $greetingName',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_bus_rounded,
                          color: GateFlowColors.brandAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        busLabel,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _BusIconBtn(
            icon: Icons.notifications_none_rounded,
            onTap: () =>
                context.pushNamed(BusNotificationsWidget.routeName),
          ),
          const SizedBox(width: 8),
          _BusIconBtn(
            icon: Icons.person_outline_rounded,
            onTap: () =>
                context.pushNamed(BusDriverProfileWidget.routeName),
          ),
        ],
      ),
    );
  }
}

class _BusIconBtn extends StatelessWidget {
  const _BusIconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(child: Icon(icon, color: Colors.white, size: 22)),
        ),
      ),
    );
  }
}

class _BusStatsRow extends StatelessWidget {
  const _BusStatsRow({
    required this.total,
    required this.onBus,
    required this.dropped,
  });

  final int total;
  final int onBus;
  final int dropped;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BusStat(
            label: 'Total',
            value: total.toString(),
            icon: Icons.people_alt_outlined,
            color: GateFlowColors.brandPrimary,
            tint: const Color(0xFFE8F0FE),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BusStat(
            label: 'On Bus',
            value: onBus.toString(),
            icon: Icons.airline_seat_recline_normal_outlined,
            color: GateFlowColors.warning,
            tint: const Color(0xFFFFF4E0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BusStat(
            label: 'Dropped',
            value: dropped.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: GateFlowColors.success,
            tint: const Color(0xFFE6F4EA),
          ),
        ),
      ],
    );
  }
}

class _BusStat extends StatelessWidget {
  const _BusStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: GateFlowColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePreviewCard extends StatelessWidget {
  const _RoutePreviewCard({required this.bus, required this.completionPct});

  final Bus? bus;
  final double completionPct;

  @override
  Widget build(BuildContext context) {
    final pct = (completionPct.clamp(0.0, 1.0) * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GateFlowColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0C3451),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route path (mock)',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: GateFlowColors.textPrimary,
                ),
              ),
              Text(
                '$pct% drop-offs',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: GateFlowColors.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  GateFlowColors.surface,
                  GateFlowColors.brandPrimary.withValues(alpha: .08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: GateFlowColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _RouteStop(label: 'School', sub: 'Depart 2:40', active: false),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              colors: [
                                GateFlowColors.brandPrimary,
                                GateFlowColors.brandAccent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _RouteStop(label: 'North A', sub: 'Stop 3', active: true),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: GateFlowColors.divider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _RouteStop(label: 'Zone D', sub: 'Terminus', active: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bus?.lastUpdateLabel ?? 'Last ping: just now (mock)',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: GateFlowColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.label,
    required this.sub,
    required this.active,
  });

  final String label;
  final String sub;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                active ? GateFlowColors.brandPrimary : GateFlowColors.divider,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: GateFlowColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: GateFlowColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DriverPrimaryActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GateFlowColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () =>
                context.pushNamed(ConfirmBoardingWidget.routeName),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(
              'Scan student',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800, fontSize: 15.5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: GateFlowColors.brandPrimary,
              side: BorderSide(color: GateFlowColors.divider),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () =>
                context.pushNamed(AssignedStudentslistWidget.routeName),
            icon: const Icon(Icons.groups_outlined),
            label: Text(
              'View student list',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

class _BusSectionTitle extends StatelessWidget {
  const _BusSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: GateFlowColors.brandPrimary,
      ),
    );
  }
}

class _BusQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = <_BusActionCard>[
      _BusActionCard(
        icon: Icons.notifications_active_outlined,
        title: 'School alerts',
        subtitle: 'Dispatch & reminders',
        tint: const Color(0xFFFFF4E0),
        iconColor: GateFlowColors.warning,
        onTap: () =>
            context.pushNamed(BusNotificationsWidget.routeName),
      ),
      _BusActionCard(
        icon: Icons.route_rounded,
        title: 'Bus status summary',
        subtitle: 'Line health (mock)',
        tint: const Color(0xFFE8F0FE),
        iconColor: GateFlowColors.brandPrimary,
        onTap: () => context.pushNamed(BusStatusViewWidget.routeName),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, i) => actions[i],
    );
  }
}

class _BusActionCard extends StatelessWidget {
  const _BusActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: GateFlowColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: GateFlowColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: GateFlowColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
