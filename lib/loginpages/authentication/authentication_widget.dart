import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import 'authentication_model.dart';

export 'authentication_model.dart';

class AuthenticationWidget extends StatefulWidget {
  const AuthenticationWidget({super.key});

  static String routeName = 'Authentication';
  static String routePath = '/authentication';

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  late AuthenticationModel _model;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuthenticationModel());
    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email =
        (_model.emailAddressTextController?.text ?? '').trim().toLowerCase();
    _enterAs(_inferRoleFromEmail(email));
  }

  UserRole _inferRoleFromEmail(String email) {
    if (email.contains('school') || email.contains('admin')) {
      return UserRole.schoolStaff;
    }
    if (email.contains('bus') || email.contains('driver')) {
      return UserRole.busDriver;
    }
    if (email.contains('guardian')) return UserRole.guardian;
    return UserRole.parent;
  }

  void _enterAs(UserRole role) {
    context.read<MockState>().loginAs(role);
    switch (role) {
      case UserRole.parent:
        context.goNamed('Dash');
        break;
      case UserRole.schoolStaff:
        context.goNamed('SchoolDashboard');
        break;
      case UserRole.busDriver:
        context.goNamed('BusSupervisorDashboard');
        break;
      case UserRole.guardian:
        context.goNamed('DashGuardian');
        break;
      case UserRole.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
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
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLoginForm(),
                                const SizedBox(height: 24),
                                const Divider(
                                    color: GateFlowColors.divider, height: 1),
                                const SizedBox(height: 20),
                                _buildDemoPicker(),
                              ],
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: GateFlowColors.brandAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.sensor_door_rounded,
                color: GateFlowColors.brandPrimary, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'GateFlow',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart school gate management',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 13,
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
              color: GateFlowColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue to your dashboard.',
            style: GoogleFonts.inter(
              color: GateFlowColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _model.emailAddressTextController,
            focusNode: _model.emailAddressFocusNode,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email', Icons.mail_outline_rounded),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Email is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _model.passwordTextController,
            focusNode: _model.passwordFocusNode,
            autofillHints: const [AutofillHints.password],
            obscureText: !_model.passwordVisibility,
            decoration:
                _inputDecoration('Password', Icons.lock_outline_rounded)
                    .copyWith(
              suffixIcon: IconButton(
                onPressed: () => safeSetState(() =>
                    _model.passwordVisibility = !_model.passwordVisibility),
                icon: Icon(
                  _model.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: GateFlowColors.textSecondary,
                ),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty)
                ? 'Password is required'
                : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  context.pushNamed(ForgotPasswordWidget.routeName),
              style: TextButton.styleFrom(
                foregroundColor: GateFlowColors.info,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Forgot your password?'),
            ),
          ),
          const SizedBox(height: 12),
          FFButtonWidget(
            onPressed: _handleLogin,
            text: 'Log In',
            options: FFButtonOptions(
              width: double.infinity,
              height: 52,
              color: GateFlowColors.brandAccent,
              textStyle: GoogleFonts.interTight(
                color: GateFlowColors.brandPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              borderRadius: BorderRadius.circular(40),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 1.4),
          borderRadius: BorderRadius.circular(14),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: GateFlowColors.textSecondary, size: 20),
      labelStyle: GoogleFonts.inter(
          color: GateFlowColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      enabledBorder: border(const Color(0xFFE2E8F0)),
      focusedBorder: border(GateFlowColors.brandPrimary),
      errorBorder: border(GateFlowColors.danger),
      focusedErrorBorder: border(GateFlowColors.danger),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _buildDemoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science_outlined,
                size: 16, color: GateFlowColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Explore as a demo user',
              style: GoogleFonts.inter(
                color: GateFlowColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _demoChip('Parent', Icons.family_restroom_rounded, UserRole.parent),
            _demoChip('Guardian', Icons.shield_outlined, UserRole.guardian),
            _demoChip('Bus Driver', Icons.directions_bus_rounded,
                UserRole.busDriver),
            _demoChip(
                'School Staff', Icons.school_rounded, UserRole.schoolStaff),
          ],
        ),
      ],
    );
  }

  Widget _demoChip(String label, IconData icon, UserRole role) {
    return InkWell(
      onTap: () => _enterAs(role),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F6FB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
