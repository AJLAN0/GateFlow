import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import 'school_dashboard_model.dart';

export 'school_dashboard_model.dart';

/// School staff (admin) dashboard.
///
/// Modernized layout: gradient hero header, live stats grid, primary
/// "Verify Pickup" CTA, and an organized 2x3 admin actions grid covering
/// every part of the system staff need to reach (system management,
/// schedules, time requests, student status, bus status, notifications).
class SchoolDashboardWidget extends StatefulWidget {
  const SchoolDashboardWidget({super.key});

  static String routeName = 'SchoolDashboard';
  static String routePath = '/schoolDashboard';

  @override
  State<SchoolDashboardWidget> createState() => _SchoolDashboardWidgetState();
}

class _SchoolDashboardWidgetState extends State<SchoolDashboardWidget> {
  late SchoolDashboardModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SchoolDashboardModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockState = context.watch<MockState>();
    final atSchool = mockState.students
        .where((s) => s.status == StudentStatus.atSchool)
        .length;
    final atHome = mockState.students
        .where((s) =>
            s.status == StudentStatus.atHome ||
            s.status == StudentStatus.pickedUpByCar)
        .length;
    final onBus = mockState.students
        .where((s) =>
            s.status == StudentStatus.onBusToHome ||
            s.status == StudentStatus.onBusToSchool)
        .length;
    final pendingRequests = mockState.requests
        .where((r) => r.status == RequestStatus.pending)
        .length;

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
              _AdminHeader(pendingCount: pendingRequests),
              const SizedBox(height: 18),
              _StatsGrid(
                atSchool: atSchool,
                onBus: onBus,
                atHome: atHome,
                pendingRequests: pendingRequests,
              ),
              const SizedBox(height: 20),
              _VerifyCta(
                onPressed: () => context.pushNamed('ParentVerification'),
              ),
              const SizedBox(height: 22),
              const _AdminSectionTitle(title: 'Management'),
              const SizedBox(height: 10),
              _AdminActionsGrid(),
            ],
          ).animate().fade(duration: 500.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
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
                  'School Admin',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Operations Center',
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
                      const Icon(Icons.admin_panel_settings_outlined,
                          color: GateFlowColors.brandAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        pendingCount > 0
                            ? '$pendingCount pending action${pendingCount == 1 ? '' : 's'}'
                            : 'All caught up',
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
          _AdminIconBtn(
            icon: Icons.notifications_none_rounded,
            badge: pendingCount > 0,
            onTap: () => context.pushNamed('SchoolNotification'),
          ),
          const SizedBox(width: 8),
          _AdminIconBtn(
            icon: Icons.person_outline_rounded,
            onTap: () => context.pushNamed('AdminProfile'),
          ),
        ],
      ),
    );
  }
}

class _AdminIconBtn extends StatelessWidget {
  const _AdminIconBtn({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

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
          child: Stack(
            children: [
              Center(child: Icon(icon, color: Colors.white, size: 22)),
              if (badge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: GateFlowColors.brandAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.atSchool,
    required this.onBus,
    required this.atHome,
    required this.pendingRequests,
  });

  final int atSchool;
  final int onBus;
  final int atHome;
  final int pendingRequests;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'At School',
            value: atSchool.toString(),
            icon: Icons.school_outlined,
            color: GateFlowColors.brandPrimary,
            tint: const Color(0xFFE8F0FE),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'On Bus',
            value: onBus.toString(),
            icon: Icons.directions_bus_rounded,
            color: GateFlowColors.warning,
            tint: const Color(0xFFFFF4E0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'At Home',
            value: atHome.toString(),
            icon: Icons.home_outlined,
            color: GateFlowColors.success,
            tint: const Color(0xFFE6F4EA),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

class _VerifyCta extends StatelessWidget {
  const _VerifyCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GateFlowColors.divider),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0C3451),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      GateFlowColors.brandAccent,
                      Color(0xFFFFE082),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: GateFlowColors.brandPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Pickup',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GateFlowColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan QR or check ID at the gate',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: GateFlowColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSectionTitle extends StatelessWidget {
  const _AdminSectionTitle({required this.title});

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

class _AdminActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = <_AdminAction>[
      _AdminAction(
        icon: Icons.settings_outlined,
        title: 'System',
        subtitle: 'Users & buses',
        tint: const Color(0xFFE8F0FE),
        iconColor: GateFlowColors.brandPrimary,
        onTap: () => context.pushNamed('SMmain'),
      ),
      _AdminAction(
        icon: Icons.event_note_outlined,
        title: 'Schedules',
        subtitle: 'Daily plan',
        tint: const Color(0xFFFFF4E0),
        iconColor: GateFlowColors.warning,
        onTap: () => context.pushNamed('ManageSchedules'),
      ),
      _AdminAction(
        icon: Icons.access_time_rounded,
        title: 'Time Requests',
        subtitle: 'Early / late',
        tint: const Color(0xFFFCE4EC),
        iconColor: const Color(0xFFD81B60),
        onTap: () => context.pushNamed('TimeRequest'),
      ),
      _AdminAction(
        icon: Icons.people_outline_rounded,
        title: 'Student Status',
        subtitle: 'Live monitor',
        tint: const Color(0xFFE6F4EA),
        iconColor: GateFlowColors.success,
        onTap: () => context.pushNamed('StudentStatus'),
      ),
      _AdminAction(
        icon: Icons.directions_bus_outlined,
        title: 'Bus Status',
        subtitle: 'Routes live',
        tint: const Color(0xFFFFE9E9),
        iconColor: GateFlowColors.danger,
        onTap: () => context.pushNamed('BusStatus'),
      ),
      _AdminAction(
        icon: Icons.notifications_active_outlined,
        title: 'Announcements',
        subtitle: 'School news',
        tint: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF7C4DFF),
        onTap: () => context.pushNamed('SchoolNotification'),
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

class _AdminAction extends StatelessWidget {
  const _AdminAction({
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
