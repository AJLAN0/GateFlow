import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../../shared/sign_out_tile.dart';
import '../../shared/status_pill.dart';
import 'profile_g_model.dart';

export 'profile_g_model.dart';

class ProfileGWidget extends StatefulWidget {
  const ProfileGWidget({super.key});

  static String routeName = 'ProfileG';
  static String routePath = '/profileG';

  @override
  State<ProfileGWidget> createState() => _ProfileGWidgetState();
}

class _ProfileGWidgetState extends State<ProfileGWidget> {
  late ProfileGModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileGModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext ctx, String title) {
    showDialog<void>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text(
          'This prototype screen is informational only.',
          style: GoogleFonts.inter(color: GateFlowColors.textSecondary, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final g = mock.guardianProfile;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: GateFlowColors.brandPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GateFlowColors.divider),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0F0C3451),
                      blurRadius: 14,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            GateFlowColors.brandPrimary.withValues(alpha: .12),
                        child: Icon(Icons.health_and_safety_rounded,
                            color: GateFlowColors.brandPrimary, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.fullName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusPill(
                              label: g.authorizationNote,
                              tone: StatusTone.success,
                              icon: Icons.verified_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(Icons.phone_rounded, g.phone),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.email_outlined, g.email),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.family_restroom_rounded, g.relationship),
                  const SizedBox(height: 6),
                  Text(
                    'Assigned students appear under Children.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: GateFlowColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Settings',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: GateFlowColors.brandPrimary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GateFlowColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GateFlowColors.brandPrimary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.notifications_active_outlined,
                        color: GateFlowColors.brandPrimary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification preferences',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mock.guardianNotifyEnabled ? 'Enabled (mock)' : 'Muted',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: GateFlowColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: mock.guardianNotifyEnabled,
                    onChanged: mock.setGuardianNotifyEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'Arabic · English (coming soon)',
              onTap: () => _comingSoon(context, 'Language'),
            ),
            const SizedBox(height: 20),
            Text(
              'Support',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: GateFlowColors.brandPrimary),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy',
              subtitle: 'Read the demo policy copy',
              onTap: () => _comingSoon(context, 'Privacy'),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help',
              subtitle: 'GateFlow guardians quick guide',
              onTap: () => _comingSoon(context, 'Help'),
            ),
            const SizedBox(height: 22),
            const SignOutTile(),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: GateFlowColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: GateFlowColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GateFlowColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GateFlowColors.brandPrimary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: GateFlowColors.brandPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 14.5)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: GateFlowColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded,
                      color: GateFlowColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
