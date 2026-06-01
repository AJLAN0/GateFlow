import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '../../backend/supabase/services/seed_service.dart';
import '../../backend/supabase/supabase_config.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import 'authentication_model.dart';

export 'authentication_model.dart';

/// Set to `true` to show demo quick sign-in + Supabase seed tools on login.
const bool kShowLoginDevTools = false;

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({super.key});

  static String routeName = 'Authentication';
  static String routePath = '/authentication';

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  late AuthenticationModel _model;
  final _formKey    = GlobalKey<FormState>();
  bool  _submitting = false;
  bool  _seeding    = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthenticationModel());
    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode      ??= FocusNode();
    _model.passwordTextController     ??= TextEditingController();
    _model.passwordFocusNode          ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email    = (_model.emailAddressTextController?.text ?? '').trim();
    final password = _model.passwordTextController?.text ?? '';

    setState(() => _submitting = true);

    final appState = context.read<MockState>();
    final error    = await appState.signInWithEmailPassword(email, password);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: GateFlowColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate based on role (set by signInWithEmailPassword)
    _navigateForRole(appState.currentUserRole);
  }

  void _navigateForRole(UserRole role) {
    switch (role) {
      case UserRole.parent:
        context.goNamed('Dash');
      case UserRole.schoolStaff:
        context.goNamed('SchoolDashboard');
      case UserRole.busDriver:
        context.goNamed('BusSupervisorDashboard');
      case UserRole.guardian:
        context.goNamed('DashGuardian');
      case UserRole.none:
        break;
    }
  }

  Future<void> _quickSignIn(DemoAccount account) async {
    if (_submitting) return;

    setState(() => _submitting = true);
    final appState = context.read<MockState>();

    String? error;
    if (isSupabaseConfigured) {
      error = await appState.signInWithEmailPassword(
        account.email,
        account.password,
      );
    } else {
      appState.loginAs(_userRoleForAccount(account));
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: GateFlowColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _navigateForRole(
      isSupabaseConfigured
          ? appState.currentUserRole
          : _userRoleForAccount(account),
    );
  }

  UserRole _userRoleForAccount(DemoAccount account) {
    switch (account.role) {
      case 'parent':
        return UserRole.parent;
      case 'school_staff':
        return UserRole.schoolStaff;
      case 'bus_driver':
        return UserRole.busDriver;
      case 'guardian':
        return UserRole.guardian;
      default:
        return UserRole.none;
    }
  }

  DemoAccount? _demoAccountForRole(UserRole role) {
    for (final account in kDemoAccounts) {
      if (_userRoleForAccount(account) == role) return account;
    }
    return null;
  }

  void _enterAs(UserRole role) {
    final account = _demoAccountForRole(role);
    if (account != null) {
      _quickSignIn(account);
      return;
    }
    context.read<MockState>().loginAs(role);
    _navigateForRole(role);
  }

  Future<void> _handleSeedAccounts() async {
    setState(() => _seeding = true);
    final results = await context.read<MockState>().seedDemoAccounts();
    if (!mounted) return;
    setState(() => _seeding = false);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Demo Account Setup'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in results)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(line, style: const TextStyle(fontSize: 13)),
                ),
              const SizedBox(height: 12),
              Text(
                'Password for all accounts: ${kDemoPassword}',
                style: const TextStyle(
                    fontSize: 12, color: GateFlowColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: GateFlowColors.brandPrimary,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildBrandHeader(),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: double.infinity,
                            constraints:
                                BoxConstraints(maxWidth: isWide ? 480 : 600),
                            margin:  const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color:        Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color:      Color(0x33000000),
                                  blurRadius: 24,
                                  offset:     Offset(0, 8),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildLoginForm(),
                                  if (kShowLoginDevTools) ...[
                                    const SizedBox(height: 20),
                                    _buildQuickSignIn(),
                                    if (!isSupabaseConfigured) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Offline mode — quick sign-in uses mock data only.',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: GateFlowColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    const Divider(
                                        color: GateFlowColors.divider,
                                        height: 1),
                                    const SizedBox(height: 16),
                                    _buildSeedSection(),
                                  ],
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .moveY(begin: 20, end: 0),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          Container(
            width:  64,
            height: 64,
            decoration: BoxDecoration(
              color:        GateFlowColors.brandAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.sensor_door_rounded,
              color: GateFlowColors.brandPrimary,
              size:  32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'GateFlow',
            style: GoogleFonts.outfit(
              color:      Colors.white,
              fontSize:   34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart school gate management',
            style: GoogleFonts.inter(
              color:       Colors.white70,
              fontSize:    13,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: GoogleFonts.interTight(
              color:      GateFlowColors.textPrimary,
              fontSize:   22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue to your dashboard.',
            style: GoogleFonts.inter(
              color:    GateFlowColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller:      _model.emailAddressTextController,
            focusNode:       _model.emailAddressFocusNode,
            autofillHints:   const [AutofillHints.email],
            keyboardType:    TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration:      _inputDecoration('Email', Icons.mail_outline_rounded),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Email is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller:      _model.passwordTextController,
            focusNode:       _model.passwordFocusNode,
            autofillHints:   const [AutofillHints.password],
            obscureText:     !_model.passwordVisibility,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: _inputDecoration('Password', Icons.lock_outline_rounded)
                .copyWith(
              suffixIcon: IconButton(
                onPressed: () => safeSetState(
                    () => _model.passwordVisibility = !_model.passwordVisibility),
                icon: Icon(
                  _model.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: GateFlowColors.textSecondary,
                ),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  context.pushNamed(ForgotPasswordWidget.routeName),
              style: TextButton.styleFrom(
                foregroundColor: GateFlowColors.info,
                padding:         EdgeInsets.zero,
                tapTargetSize:   MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Forgot your password?'),
            ),
          ),
          const SizedBox(height: 12),
          FFButtonWidget(
            onPressed: _submitting ? null : _handleLogin,
            text: _submitting ? 'Signing in…' : 'Sign In',
            options: FFButtonOptions(
              width:  double.infinity,
              height: 52,
              color: _submitting
                  ? GateFlowColors.divider
                  : GateFlowColors.brandAccent,
              textStyle: GoogleFonts.interTight(
                color:      GateFlowColors.brandPrimary,
                fontWeight: FontWeight.bold,
                fontSize:   16,
              ),
              borderRadius: BorderRadius.circular(40),
              elevation:    0,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderSide:   BorderSide(color: color, width: 1.4),
          borderRadius: BorderRadius.circular(14),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: GateFlowColors.textSecondary, size: 20),
      labelStyle: GoogleFonts.inter(
          color: GateFlowColors.textSecondary, fontSize: 14),
      filled:             true,
      fillColor:          const Color(0xFFF7F9FC),
      enabledBorder:      border(const Color(0xFFE2E8F0)),
      focusedBorder:      border(GateFlowColors.brandPrimary),
      errorBorder:        border(GateFlowColors.danger),
      focusedErrorBorder: border(GateFlowColors.danger),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildQuickSignIn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded,
                size: 16, color: GateFlowColors.brandPrimary),
            const SizedBox(width: 6),
            Text(
              isSupabaseConfigured
                  ? 'Quick sign in (demo accounts)'
                  : 'Explore as a demo user',
              style: GoogleFonts.inter(
                color: GateFlowColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'One tap — password is $kDemoPassword for all roles.',
          style: GoogleFonts.inter(
            color: GateFlowColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _demoChip('Parent', Icons.family_restroom_rounded, UserRole.parent),
            _demoChip('School Staff', Icons.school_rounded, UserRole.schoolStaff),
            _demoChip('Bus Driver', Icons.directions_bus_rounded, UserRole.busDriver),
            _demoChip('Guardian', Icons.shield_outlined, UserRole.guardian),
          ],
        ),
      ],
    );
  }
  Widget _buildSeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.manage_accounts_outlined,
                size: 16, color: GateFlowColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Backend setup',
              style: GoogleFonts.inter(
                color:        GateFlowColors.textSecondary,
                fontSize:     12,
                fontWeight:   FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Creates one Supabase account per role if they don\'t exist yet. '
          'All use the shared password: $kDemoPassword',
          style: GoogleFonts.inter(
            color:    GateFlowColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        _AccountRow(
          email: 'parent@demo.gateflow.app',
          label: 'Parent',
          icon: Icons.family_restroom_rounded,
          onTap: _submitting
              ? null
              : () => _quickSignIn(
                    kDemoAccounts.firstWhere((a) => a.role == 'parent'),
                  ),
        ),
        _AccountRow(
          email: 'staff@demo.gateflow.app',
          label: 'School Staff',
          icon: Icons.school_rounded,
          onTap: _submitting
              ? null
              : () => _quickSignIn(
                    kDemoAccounts.firstWhere((a) => a.role == 'school_staff'),
                  ),
        ),
        _AccountRow(
          email: 'driver@demo.gateflow.app',
          label: 'Bus Driver',
          icon: Icons.directions_bus_rounded,
          onTap: _submitting
              ? null
              : () => _quickSignIn(
                    kDemoAccounts.firstWhere((a) => a.role == 'bus_driver'),
                  ),
        ),
        _AccountRow(
          email: 'guardian@demo.gateflow.app',
          label: 'Guardian',
          icon: Icons.shield_outlined,
          onTap: _submitting
              ? null
              : () => _quickSignIn(
                    kDemoAccounts.firstWhere((a) => a.role == 'guardian'),
                  ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _seeding ? null : _handleSeedAccounts,
            icon: _seeding
                ? const SizedBox(
                    width:  14,
                    height: 14,
                    child:  CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined, size: 16),
            label: Text(
              _seeding ? 'Creating accounts…' : 'Create demo accounts on Supabase',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: GateFlowColors.brandPrimary,
              side: const BorderSide(color: GateFlowColors.brandPrimary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _demoChip(String label, IconData icon, UserRole role) {
    return InkWell(
      onTap: _submitting ? null : () => _enterAs(role),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: GateFlowColors.brandPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: GateFlowColors.brandPrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: GateFlowColors.brandPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: GateFlowColors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String email;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _AccountRow({
    required this.email,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Icon(icon, size: 14, color: GateFlowColors.brandPrimary),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: GateFlowColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            email,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: GateFlowColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(Icons.login_rounded,
              size: 14, color: GateFlowColors.brandPrimary),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: row,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: row,
          ),
        ),
      ),
    );
  }
}
