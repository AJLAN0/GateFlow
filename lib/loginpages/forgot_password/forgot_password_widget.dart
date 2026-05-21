import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../backend/supabase/services/auth_service.dart';
import '../../backend/supabase/supabase_config.dart';
import '../../shared/gateflow_colors.dart';
import 'forgot_password_model.dart';

export 'forgot_password_model.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  static String routeName = 'ForgotPassword';
  static String routePath = '/forgotPassword';

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  late ForgotPasswordModel _model;
  final _formKey    = GlobalKey<FormState>();
  bool  _submitting = false;
  bool  _sent       = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForgotPasswordModel());
    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode      ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = (_model.emailAddressTextController?.text ?? '').trim();

    setState(() => _submitting = true);

    try {
      if (isSupabaseConfigured) {
        await AuthService.instance.resetPassword(email);
      }
      if (!mounted) return;
      setState(() { _sent = true; _submitting = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(e.toString()),
          backgroundColor: GateFlowColors.danger,
          behavior:        SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor:      const Color(0xFF0C3451),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor:  Colors.transparent,
          borderRadius: 30.0,
          borderWidth:  1.0,
          buttonSize:   60.0,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Reset Password',
          style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.outfit(
                  fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  fontStyle:  FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
                color:       Colors.white,
                fontSize:    24,
                letterSpacing: 0,
              ),
        ),
        elevation: 2,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 570),
          padding: const EdgeInsets.all(20),
          child: _sent ? _buildSuccessState() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          TextFormField(
            controller:    _model.emailAddressTextController,
            focusNode:     _model.emailAddressFocusNode,
            autofillHints: const [AutofillHints.email],
            keyboardType:  TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendLink(),
            decoration: InputDecoration(
              labelText:   'Your email address',
              hintText:    'Enter your email…',
              prefixIcon:  const Icon(Icons.mail_outline_rounded, size: 20),
              filled:      true,
              fillColor:   FlutterFlowTheme.of(context).secondaryBackground,
              enabledBorder: OutlineInputBorder(
                borderSide:   BorderSide(color: FlutterFlowTheme.of(context).alternate, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:   const BorderSide(color: Color(0xFF0C3451), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide:   BorderSide(color: FlutterFlowTheme.of(context).error, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide:   BorderSide(color: FlutterFlowTheme.of(context).error, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'We will send you an email with a link to reset your password.',
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                    fontStyle:  FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  ),
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 20),
          FFButtonWidget(
            onPressed: _submitting ? null : _sendLink,
            text: _submitting ? 'Sending…' : 'Send Reset Link',
            options: FFButtonOptions(
              width:  double.infinity,
              height: 56,
              color:  _submitting ? GateFlowColors.divider : const Color(0xFFF7C530),
              textStyle: GoogleFonts.interTight(
                fontWeight: FontWeight.bold,
                color:      const Color(0xFF0C3451),
                fontSize:   16,
              ),
              elevation:    3,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width:  72,
          height: 72,
          decoration: BoxDecoration(
            color:        GateFlowColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              color: GateFlowColors.success, size: 36),
        ),
        const SizedBox(height: 20),
        Text(
          'Check your inbox',
          style: GoogleFonts.interTight(
            fontSize:   22,
            fontWeight: FontWeight.bold,
            color:      GateFlowColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A password reset link has been sent to\n${_model.emailAddressTextController?.text ?? ''}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color:    GateFlowColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        TextButton(
          onPressed: () => context.safePop(),
          child: Text(
            'Back to Sign In',
            style: GoogleFonts.inter(
              color:      GateFlowColors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
