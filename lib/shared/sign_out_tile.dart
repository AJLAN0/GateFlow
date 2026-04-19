import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/mock_state.dart';
import 'gateflow_colors.dart';

/// Reusable tappable Sign Out row used by every profile screen.
///
/// Previously each profile rendered a static, non-interactive Sign Out row,
/// leaving users with no way to change role or exit a session.
class SignOutTile extends StatelessWidget {
  const SignOutTile({super.key});

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will return to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: GateFlowColors.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    context.read<MockState>().loginAs(UserRole.none);
    context.goNamed('Authentication');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _confirmAndSignOut(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GateFlowColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: GateFlowColors.danger, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    color: GateFlowColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right_rounded,
                color: GateFlowColors.danger, size: 20),
          ],
        ),
      ),
    );
  }
}
