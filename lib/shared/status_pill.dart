import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gateflow_colors.dart';

/// Tone-aware status pill used across requests, students, buses, and approvals.
///
/// Replaces ~40 ad-hoc Container+Text pairs scattered across pages so every
/// "Pending / Approved / On Bus / Dropped Off" badge looks identical.
enum StatusTone { pending, approved, rejected, info, neutral, success }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.dense = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(tone);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: palette.foreground),
            SizedBox(width: dense ? 4 : 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              color: palette.foreground,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  _Palette _palette(StatusTone t) {
    switch (t) {
      case StatusTone.pending:
        return const _Palette(
            GateFlowColors.pending, GateFlowColors.pendingText);
      case StatusTone.approved:
      case StatusTone.success:
        return const _Palette(
            GateFlowColors.approved, GateFlowColors.approvedText);
      case StatusTone.rejected:
        return const _Palette(
            GateFlowColors.rejected, GateFlowColors.rejectedText);
      case StatusTone.info:
        return const _Palette(Color(0xFFE3F0FB), GateFlowColors.info);
      case StatusTone.neutral:
        return const _Palette(
            Color(0xFFF1F2F5), GateFlowColors.textSecondary);
    }
  }
}

class _Palette {
  const _Palette(this.background, this.foreground);
  final Color background;
  final Color foreground;
}
