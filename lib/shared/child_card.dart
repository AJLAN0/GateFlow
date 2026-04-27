import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gateflow_colors.dart';

/// Transport mode for a tracked child.
enum ChildTransport { bus, car }

/// Modern, reusable child tracking card used on parent / guardian
/// "View Children" screens.
///
/// Replaces ~250 lines of duplicated boilerplate per card with a single
/// component that handles avatar, transport label, attendance chips, and
/// tap-to-details navigation in a consistent, modern layout.
class ChildCard extends StatelessWidget {
  const ChildCard({
    super.key,
    required this.name,
    required this.grade,
    required this.transport,
    required this.emoji,
    required this.avatarTint,
    required this.attendancePresent,
    required this.onAttendanceChanged,
    required this.onTap,
  });

  final String name;
  final String grade;
  final ChildTransport transport;
  final String emoji;
  final Color avatarTint;
  final bool attendancePresent;
  final ValueChanged<bool> onAttendanceChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final transportLabel =
        transport == ChildTransport.bus ? 'School Bus' : 'Private Car';
    final transportColor = transport == ChildTransport.bus
        ? GateFlowColors.success
        : GateFlowColors.info;

    return Container(
      decoration: BoxDecoration(
        color: GateFlowColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0C3451),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(emoji: emoji, tint: avatarTint),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.interTight(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: GateFlowColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            grade,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: GateFlowColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _TransportBadge(
                            label: transportLabel,
                            color: transportColor,
                            icon: transport == ChildTransport.bus
                                ? Icons.directions_bus_rounded
                                : Icons.directions_car_rounded,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: GateFlowColors.textTertiary,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: GateFlowColors.divider),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                    _AttendanceToggle(
                      present: attendancePresent,
                      onChanged: onAttendanceChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.emoji, required this.tint});

  final String emoji;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: tint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    );
  }
}

class _TransportBadge extends StatelessWidget {
  const _TransportBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceToggle extends StatelessWidget {
  const _AttendanceToggle({
    required this.present,
    required this.onChanged,
  });

  final bool present;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: GateFlowColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Chip(
            label: 'Present',
            selected: present,
            color: GateFlowColors.success,
            onTap: () => onChanged(true),
          ),
          _Chip(
            label: 'Absent',
            selected: !present,
            color: GateFlowColors.danger,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : GateFlowColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
