import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/role_bottom_nav.dart';
import 'dash_guardian_model.dart';

export 'dash_guardian_model.dart';

/// Guardian home dashboard.
///
/// Mirrors the modern parent dashboard layout but tailored for guardians:
/// no "create request" CTA (guardians don't initiate pickup requests),
/// emphasis on tracking children and viewing requests they've been assigned.
class DashGuardianWidget extends StatefulWidget {
  const DashGuardianWidget({super.key});

  static String routeName = 'DashGuardian';
  static String routePath = '/dashGuardian';

  @override
  State<DashGuardianWidget> createState() => _DashGuardianWidgetState();
}

class _DashGuardianWidgetState extends State<DashGuardianWidget> {
  late DashGuardianModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashGuardianModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockState = context.watch<MockState>();
    final latestReq =
        mockState.requests.isNotEmpty ? mockState.requests.last : null;
    final pendingCount = mockState.requests
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
              _GHeader(
                name: 'Mohammed',
                pendingCount: pendingCount,
              ),
              const SizedBox(height: 22),
              const _GSectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 10),
              _GQuickActions(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _GSectionTitle(title: 'Latest Request'),
                  if (latestReq != null)
                    TextButton(
                      onPressed: () =>
                          context.pushNamed(RequestStatusWidget.routeName),
                      child: Text(
                        'See details',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: GateFlowColors.brandPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _GLatestRequestCard(request: latestReq),
            ],
          ).animate().fade(duration: 500.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }
}

class _GHeader extends StatelessWidget {
  const _GHeader({required this.name, required this.pendingCount});

  final String name;
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
                  'Guardian Portal',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hello, $name',
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
                      const Icon(Icons.shield_outlined,
                          color: GateFlowColors.brandAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        pendingCount > 0
                            ? '$pendingCount request${pendingCount == 1 ? '' : 's'} awaiting'
                            : 'All clear',
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
          _GIconBtn(
            icon: Icons.notifications_none_rounded,
            badge: pendingCount > 0,
            onTap: () => context.pushNamed('NotificationsG'),
          ),
          const SizedBox(width: 8),
          _GIconBtn(
            icon: Icons.person_outline_rounded,
            onTap: () => context.pushNamed(ProfileGWidget.routeName),
          ),
        ],
      ),
    );
  }
}

class _GIconBtn extends StatelessWidget {
  const _GIconBtn({
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

class _GSectionTitle extends StatelessWidget {
  const _GSectionTitle({required this.title});

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

class _GQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = <_GQuickAction>[
      _GQuickAction(
        icon: Icons.child_care_rounded,
        title: 'View Children',
        subtitle: 'Track & monitor',
        tint: const Color(0xFFE8F0FE),
        iconColor: GateFlowColors.brandPrimary,
        onTap: () => context.pushNamed(ViewChildernGWidget.routeName),
      ),
      _GQuickAction(
        icon: Icons.fact_check_outlined,
        title: 'Requests',
        subtitle: 'View status',
        tint: const Color(0xFFFFF4E0),
        iconColor: GateFlowColors.warning,
        onTap: () => context.pushNamed(RequestStatusWidget.routeName),
      ),
      _GQuickAction(
        icon: Icons.notifications_active_outlined,
        title: 'Notifications',
        subtitle: 'School updates',
        tint: const Color(0xFFFCE4EC),
        iconColor: const Color(0xFFD81B60),
        onTap: () => context.pushNamed('NotificationsG'),
      ),
      _GQuickAction(
        icon: Icons.account_circle_outlined,
        title: 'My Profile',
        subtitle: 'Account info',
        tint: const Color(0xFFE6F4EA),
        iconColor: GateFlowColors.success,
        onTap: () => context.pushNamed(ProfileGWidget.routeName),
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

class _GQuickAction extends StatelessWidget {
  const _GQuickAction({
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

class _GLatestRequestCard extends StatelessWidget {
  const _GLatestRequestCard({required this.request});

  final ParentRequest? request;

  @override
  Widget build(BuildContext context) {
    if (request == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GateFlowColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: GateFlowColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: GateFlowColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No assigned requests yet.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: GateFlowColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final r = request!;
    final tone = _toneFor(r.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => context.pushNamed(RequestStatusWidget.routeName),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
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
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_bus_rounded,
                        color: GateFlowColors.brandPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.type,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: GateFlowColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(r.date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: GateFlowColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: tone.bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: tone.fg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel(r.status),
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: tone.fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: GateFlowColors.divider),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GMetaItem(label: 'Pickup Time', value: '3:30 PM'),
                  _GMetaItem(label: 'Parent', value: 'Khalid'),
                  _GMetaItem(label: 'Child', value: 'Omar'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  static _GTone _toneFor(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return const _GTone(
            bg: GateFlowColors.pending, fg: GateFlowColors.pendingText);
      case RequestStatus.approved:
        return const _GTone(
            bg: GateFlowColors.approved, fg: GateFlowColors.approvedText);
      case RequestStatus.rejected:
        return const _GTone(
            bg: GateFlowColors.rejected, fg: GateFlowColors.rejectedText);
    }
  }

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'Today';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _GTone {
  const _GTone({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}

class _GMetaItem extends StatelessWidget {
  const _GMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: GateFlowColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: GateFlowColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
