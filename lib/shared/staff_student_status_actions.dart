import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/mock_state.dart';
import 'gateflow_colors.dart';
import 'student_status_helpers.dart';

/// Staff actions on the student detail screen: check-in and dismissal verification.
class StaffStudentStatusActions extends StatelessWidget {
  const StaffStudentStatusActions({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  Widget build(BuildContext context) {
    final mock = context.read<MockState>();
    final canCheckIn = mock.canStaffCheckInStudent(student);
    final canDismiss = mock.canStaffMarkWaitingDismissal(student);
    final canRelease = mock.canReleaseStudentAtGate(student);
    final blockReason = mock.gateReleaseBlockReason(student);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GateFlowColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff actions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: GateFlowColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            studentStatusCopy(student),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GateFlowColors.brandPrimary,
            ),
          ),
          if (student.lastMockUpdateLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              student.lastMockUpdateLabel,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: GateFlowColors.textTertiary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (canCheckIn)
            _ActionButton(
              icon: Icons.login_rounded,
              label: 'Check in at school',
              subtitle: 'Student arrived on campus',
              color: GateFlowColors.brandPrimary,
              onPressed: () {
                mock.staffCheckInStudent(student.id);
                _showSnack(context, '${student.name} checked in.');
              },
            ),
          if (canDismiss) ...[
            if (canCheckIn) const SizedBox(height: 10),
            _ActionButton(
              icon: Icons.exit_to_app_rounded,
              label: 'Mark waiting dismissal',
              subtitle: 'Verified to leave campus · enables gate release',
              color: GateFlowColors.brandAccent,
              onPressed: () {
                mock.staffMarkWaitingDismissal(student.id);
                _showSnack(
                  context,
                  '${student.name} ready for pickup / bus boarding.',
                );
              },
            ),
          ],
          if (!canCheckIn && !canDismiss && !canRelease) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GateFlowColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                blockReason ?? 'No staff action available for this status.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: GateFlowColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
          ],
          if (canRelease) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GateFlowColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GateFlowColors.success.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded,
                      color: GateFlowColors.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ready for gate release. Use Gate Verification to hand over to parent/guardian.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: GateFlowColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: GateFlowColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: GateFlowColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
