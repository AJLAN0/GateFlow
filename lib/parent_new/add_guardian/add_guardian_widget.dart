import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/mock_state.dart';
import '../../shared/gateflow_app_bar.dart';
import '../../shared/gateflow_colors.dart';
import 'add_guardian_model.dart';

export 'add_guardian_model.dart';

class AddGuardianWidget extends StatefulWidget {
  const AddGuardianWidget({super.key});

  static String routeName = 'AddGuardian';
  static String routePath = '/addGuardian';

  @override
  State<AddGuardianWidget> createState() => _AddGuardianWidgetState();
}

class _AddGuardianWidgetState extends State<AddGuardianWidget> {
  late AddGuardianModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  OutlineInputBorder _outline(Color c) => OutlineInputBorder(
        borderSide: BorderSide(color: c, width: 1.4),
        borderRadius: BorderRadius.circular(14),
      );

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: GateFlowColors.textTertiary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: _outline(const Color(0xFFE2E8F0)),
      focusedBorder: _outline(GateFlowColors.brandPrimary),
      errorBorder: _outline(GateFlowColors.danger),
      focusedErrorBorder: _outline(GateFlowColors.danger),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: GateFlowColors.textPrimary,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddGuardianModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.dropDownValueController ??= FormFieldController<String>(null);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_model.formKey.currentState?.validate() ?? false)) return;
    if (_model.dropDownValue == null || _model.dropDownValue!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a relationship.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final m = context.read<MockState>();
    final name = _model.textController1!.text.trim();
    final nationalId = _model.textController2!.text.trim();
    final phone = _model.textController3!.text.trim();
    final relation = _model.dropDownValue!.trim();
    final carModel = _model.textController4?.text.trim() ?? '';
    final plate = _model.textController5?.text.trim() ?? '';

    m.submitPendingGuardianInvite(
      PendingGuardianInvite(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        fullName: name,
        phone: '$phone · ID $nationalId · $carModel · $plate',
        relationship: relation,
        forChildrenSummary: 'Applies to tracked children (mock)',
        status: GuardianInviteStatus.pending,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent — pending school approval (mock).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.safePop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: GateFlowColors.surface,
        appBar: const GateFlowAppBar(title: 'Add a Guardian'),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Form(
                key: _model.formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: GateFlowColors.divider),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F0C3451),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Full Name *'),
                      TextFormField(
                        controller: _model.textController1,
                        focusNode: _model.textFieldFocusNode1,
                        textCapitalization: TextCapitalization.words,
                        decoration: _fieldDecoration(
                            'Example: Sarah Ahmed'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Full name is required'
                            : null,
                        inputFormatters: [
                          if (!isAndroid && !isiOS)
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              return TextEditingValue(
                                selection: newValue.selection,
                                text: newValue.text.toCapitalization(
                                    TextCapitalization.words),
                              );
                            }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _label('Phone Number *'),
                      TextFormField(
                        controller: _model.textController3,
                        focusNode: _model.textFieldFocusNode3,
                        keyboardType: TextInputType.phone,
                        decoration: _fieldDecoration(
                            'Example: +9665XXXXXXXX'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Phone number is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _label('Relationship *'),
                      FlutterFlowDropDown<String>(
                        controller: _model.dropDownValueController!,
                        options: const [
                          'Father',
                          'Mother',
                          'Brother',
                          'Sister',
                          'Uncle',
                          'Aunt',
                          'Family Friend',
                          'Other'
                        ],
                        onChanged: (val) =>
                            safeSetState(() => _model.dropDownValue = val),
                        width: double.infinity,
                        height: 52,
                        textStyle: GoogleFonts.inter(
                          color: GateFlowColors.textPrimary,
                          fontSize: 15,
                        ),
                        hintText: 'Example: Uncle, Aunt, Family Friend',
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: GateFlowColors.textSecondary),
                        fillColor: Colors.white,
                        elevation: 2.0,
                        borderColor: const Color(0xFFE2E8F0),
                        borderWidth: 1.5,
                        borderRadius: 14,
                        margin: EdgeInsets.zero,
                        hidesUnderline: true,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                      const SizedBox(height: 20),
                      _label('National ID / Iqama *'),
                      TextFormField(
                        controller: _model.textController2,
                        focusNode: _model.textFieldFocusNode2,
                        keyboardType: TextInputType.number,
                        decoration:
                            _fieldDecoration('Example: 1234567890'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'National ID is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Vehicle (optional)',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: GateFlowColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _label('Car model'),
                      TextFormField(
                        controller: _model.textController4,
                        focusNode: _model.textFieldFocusNode4,
                        decoration:
                            _fieldDecoration('Example: Toyota Camry'),
                      ),
                      const SizedBox(height: 18),
                      _label('License plate'),
                      TextFormField(
                        controller: _model.textController5,
                        focusNode: _model.textFieldFocusNode5,
                        decoration: _fieldDecoration('Example: ABC 1234'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FFButtonWidget(
                onPressed: () => _submit(context),
                text: 'Submit guardian request',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 54,
                  color: GateFlowColors.brandAccent,
                  textStyle: GoogleFonts.interTight(
                    color: GateFlowColors.brandPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
