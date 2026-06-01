import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_state.dart';
import 'request_pic_dro_model.dart';
export 'request_pic_dro_model.dart';

/// Create a page Design a clean and modern mobile page titled “Request Pickup
/// / Dropoff”.
///
/// At the top, include a header with a back button and page title. Below,
/// display a rounded student card with avatar, student name, and grade badge.
/// Add a selection section for request type with two options: “Early Pickup”
/// and “Late Dropoff”, styled as selectable cards or radio buttons. Only one
/// option can be active at a time. When either option is selected, show a
/// time picker card with a dropdown field (e.g., 2:30 PM). Below, add a
/// “Pickup Person” section with two choices: “I will pick up my child” and
/// “Authorized person will pick up”. If authorized is selected, enable a
/// dropdown labeled “Select Authorized Guardian”. Keep consistent spacing,
/// rounded cards, soft shadows, and clear typography. Add helper text under
/// time. Include a read-only “Request Status” label. At the bottom, place a
/// primary button labeled “Submit Request”.
class RequestPicDroWidget extends StatefulWidget {
  const RequestPicDroWidget({super.key});

  static String routeName = 'requestPicDro';
  static String routePath = '/requestPicDro';

  @override
  State<RequestPicDroWidget> createState() => _RequestPicDroWidgetState();
}

class _RequestPicDroWidgetState extends State<RequestPicDroWidget> {
  late RequestPicDroModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _earlyPickup = true;
  bool _parentSelfPickup = true;
  TimeOfDay _requestTime = const TimeOfDay(hour: 15, minute: 30);

  static const List<String> _guardianChoices = [
    'Mohammed Ali · Uncle',
    'Deem Khaled · Aunt',
  ];

  String _formatTime(BuildContext context, TimeOfDay t) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        t,
        alwaysUse24HourFormat: false,
      );

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RequestPicDroModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  DemoParentChild _pickedChild(BuildContext context) {
    final cid = GoRouterState.of(context).uri.queryParameters['cid'];
    final m = context.read<MockState>();
    if (cid != null) {
      final c = m.demoChild(cid);
      if (c != null) return c;
    }
    return m.parentDemoChildren.first;
  }

  @override
  Widget build(BuildContext context) {
    final picked = _pickedChild(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Color(0xFF0C3451),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Text(
            'Request Pickup / Dropoff ',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.outfit(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  fontSize: 24.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16.0,
                              color: FlutterFlowTheme.of(context).alternate,
                              offset: Offset(
                                0.0,
                                6.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 12.0,
                                  color: Color(0x1A4A90D9),
                                  offset: Offset(
                                    0.0,
                                    4.0,
                                  ),
                                )
                              ],
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: 56.0,
                                    height: 56.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE8F0FE),
                                      borderRadius: BorderRadius.circular(28.0),
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF0C3451),
                                        size: 28.0,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'STUDENT',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF8A94A6),
                                                fontSize: 11.0,
                                                letterSpacing: 1.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        Text(
                                          picked.name,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF1A2340),
                                                fontSize: 17.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE8F0FE),
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 4.0, 8.0, 4.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.school_rounded,
                                                      color: Color(0xFF0C3451),
                                                      size: 13.0,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  4.0,
                                                                  0.0),
                                                      child: Text(
                                                        '${picked.grade} ',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .labelSmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: Color(
                                                                  0xFF0C3451),
                                                              fontSize: 12.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 6.0)),
                                        ),
                                      ].divide(SizedBox(height: 4.0)),
                                    ),
                                  ),
                                ].divide(SizedBox(width: 16.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12.0,
                                color: Color(0x1A000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Type',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFF1A1A2E),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .fontStyle,
                                      ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _earlyPickup = true),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _earlyPickup
                                          ? const Color(0xFFF0EFFD)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: _earlyPickup
                                            ? const Color(0xFF0C3451)
                                            : const Color(0xFFE8EAF0),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 22.0,
                                            height: 22.0,
                                            decoration: BoxDecoration(
                                              color: _earlyPickup
                                                  ? const Color(0xFF0C3451)
                                                  : const Color(0xFFE8EAF0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: _earlyPickup
                                                ? Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 12.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Early Pickup',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              _earlyPickup
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: _earlyPickup
                                                            ? Color(0xFF0C3451)
                                                            : Color(0xFF6B7280),
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight: _earlyPickup
                                                            ? FontWeight.bold
                                                            : FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Pick up your child before dismissal',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color: _earlyPickup
                                                            ? Color(0xFF6B7280)
                                                            : Color(0xFF9CA3AF),
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.directions_walk_rounded,
                                            color: _earlyPickup
                                                ? const Color(0xFF0C3451)
                                                : const Color(0xFFCBD0D8),
                                            size: 22.0,
                                          ),
                                        ].divide(SizedBox(width: 12.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _earlyPickup = false),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: !_earlyPickup
                                          ? const Color(0xFFF0EFFD)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: !_earlyPickup
                                            ? const Color(0xFF0C3451)
                                            : const Color(0xFFE8EAF0),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 22.0,
                                            height: 22.0,
                                            decoration: BoxDecoration(
                                              color: !_earlyPickup
                                                  ? const Color(0xFF0C3451)
                                                  : const Color(0xFFE8EAF0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: !_earlyPickup
                                                ? const Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 12.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Late Dropoff',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              !_earlyPickup
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: !_earlyPickup
                                                            ? Color(0xFF0C3451)
                                                            : Color(0xFF6B7280),
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            !_earlyPickup
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Drop off your child after school starts',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color: !_earlyPickup
                                                            ? Color(0xFF6B7280)
                                                            : Color(0xFF9CA3AF),
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.schedule_rounded,
                                            color: !_earlyPickup
                                                ? const Color(0xFF0C3451)
                                                : const Color(0xFFCBD0D8),
                                            size: 22.0,
                                          ),
                                        ].divide(SizedBox(width: 12.0)),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 12.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12.0,
                                color: Color(0x1A000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: Color(0xFF0C3451),
                                      size: 18.0,
                                    ),
                                    Text(
                                      _earlyPickup
                                          ? 'Pickup time'
                                          : 'Drop-off time',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF1A1A2E),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 6.0)),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.0),
                                    onTap: () async {
                                      final t = await showTimePicker(
                                        context: context,
                                        initialTime: _requestTime,
                                      );
                                      if (t != null) {
                                        setState(() => _requestTime = t);
                                      }
                                    },
                                    child: Ink(
                                      width: double.infinity,
                                      height: 52.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF5F6FA),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: Color(0xFFE8EAF0),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            14.0, 0.0, 10.0, 0.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _formatTime(
                                                    context, _requestTime),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFF1A1A2E),
                                                      fontSize: 15.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.schedule_rounded,
                                              color: Color(0xFF4F46E5),
                                              size: 22.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFF9CA3AF),
                                      size: 14.0,
                                    ),
                                    Expanded(
                                      child: Text(
                                        _earlyPickup
                                            ? 'Please request at least 30 minutes before the usual dismissal time when possible.'
                                            : 'Please choose when your child will arrive after school has started.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.normal,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 11.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 6.0)),
                                ),
                              ].divide(SizedBox(height: 10.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12.0,
                                color: Color(0x1A000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF0C3451),
                                      size: 18.0,
                                    ),
                                    Text(
                                      'Pickup Person',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF1A1A2E),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 6.0)),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _parentSelfPickup = true),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _parentSelfPickup
                                          ? Color(0xFFF0EFFD)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: _parentSelfPickup
                                            ? Color(0xFF0C3451)
                                            : Color(0xFFE8EAF0),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 22.0,
                                            height: 22.0,
                                            decoration: BoxDecoration(
                                              color: _parentSelfPickup
                                                  ? Color(0xFF0C3451)
                                                  : Color(0xFFE8EAF0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: _parentSelfPickup
                                                ? Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 12.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'I will pick up my child',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              _parentSelfPickup
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: _parentSelfPickup
                                                            ? Color(0xFF0C3451)
                                                            : Color(0xFF6B7280),
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            _parentSelfPickup
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'You are listed as a primary guardian',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color: _parentSelfPickup
                                                            ? Color(0xFF6B7280)
                                                            : Color(0xFF9CA3AF),
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.how_to_reg_rounded,
                                            color: _parentSelfPickup
                                                ? Color(0xFF0C3451)
                                                : Color(0xFFCBD0D8),
                                            size: 20.0,
                                          ),
                                        ].divide(SizedBox(width: 12.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _parentSelfPickup = false),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: !_parentSelfPickup
                                          ? Color(0xFFF0EFFD)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: !_parentSelfPickup
                                            ? Color(0xFF0C3451)
                                            : Color(0xFFE8EAF0),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 22.0,
                                            height: 22.0,
                                            decoration: BoxDecoration(
                                              color: !_parentSelfPickup
                                                  ? Color(0xFF0C3451)
                                                  : Color(0xFFE8EAF0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: !_parentSelfPickup
                                                ? const Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 12.0,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Authorized person will pick up',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              !_parentSelfPickup
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            !_parentSelfPickup
                                                                ? Color(
                                                                    0xFF0C3451)
                                                                : Color(
                                                                    0xFF6B7280),
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            !_parentSelfPickup
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Select from your authorized guardians',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            !_parentSelfPickup
                                                                ? Color(
                                                                    0xFF6B7280)
                                                                : Color(
                                                                    0xFF9CA3AF),
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.people_alt_rounded,
                                            color: !_parentSelfPickup
                                                ? Color(0xFF0C3451)
                                                : Color(0xFFCBD0D8),
                                            size: 20.0,
                                          ),
                                        ].divide(SizedBox(width: 12.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_parentSelfPickup)
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F6FA),
                                      borderRadius: BorderRadius.circular(14.0),
                                      border: Border.all(
                                        color: Color(0xFFE8EAF0),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 10.0, 12.0, 10.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 6.0),
                                            child: Text(
                                              'Select Authorized Guardian',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color: Color(0xFF9CA3AF),
                                                    fontSize: 11.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ),
                                          FlutterFlowDropDown<String>(
                                            controller: _model
                                                    .dropDownValueController2 ??=
                                                FormFieldController<String>(
                                                    null),
                                            options: _guardianChoices,
                                            onChanged: (val) => safeSetState(
                                                () => _model.dropDownValue2 =
                                                    val),
                                            width: double.infinity,
                                            height: 44.0,
                                            textStyle: FlutterFlowTheme.of(
                                                    context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF1A2340),
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                            hintText: '  Select a guardian',
                                            icon: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Color(0xFF4F46E5),
                                              size: 20.0,
                                            ),
                                            fillColor: Colors.white,
                                            elevation: 0.0,
                                            borderColor: Color(0xFFE8EAF0),
                                            borderWidth: 1.0,
                                            borderRadius: 10.0,
                                            margin:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            hidesUnderline: true,
                                            isSearchable: false,
                                            isMultiSelect: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ].divide(SizedBox(height: 12.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12.0,
                                color: Color(0x1A4A90D9),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.edit_note_rounded,
                                      color: Color(0xFF0C3451),
                                      size: 20.0,
                                    ),
                                    Text(
                                      'Reason for Early Pickup / Late Dropoff',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF1A2340),
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Color(0xFFE0E7F5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: TextFormField(
                                          controller: _model.textController,
                                          focusNode: _model.textFieldFocusNode,
                                          autofocus: false,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            hintText:
                                                'e.g. Medical appointment, family emergency...',
                                            hintStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: Color(0xFFB0BAC8),
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.all(16.0),
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF1A2340),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          maxLines: 3,
                                          minLines: 3,
                                          keyboardType: TextInputType.multiline,
                                          validator: _model
                                              .textControllerValidator
                                              .asValidator(context),
                                          inputFormatters: [
                                            if (!isAndroid && !isiOS)
                                              TextInputFormatter.withFunction(
                                                  (oldValue, newValue) {
                                                return TextEditingValue(
                                                  selection: newValue.selection,
                                                  text: newValue.text
                                                      .toCapitalization(
                                                          TextCapitalization
                                                              .sentences),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ].divide(SizedBox(height: 14.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 6.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () {
                            final m = context.read<MockState>();
                            final cid = GoRouterState.of(context)
                                    .uri
                                    .queryParameters['cid'] ??
                                picked.id;
                            final reason =
                                _model.textController?.text.trim() ?? '';
                            final who = _parentSelfPickup
                                ? 'Parent (self pickup)'
                                : (_model.dropDownValue2 ??
                                    (_guardianChoices.isNotEmpty
                                        ? _guardianChoices.first
                                        : 'Authorized guardian'));
                            final pickupPersonSummary =
                                reason.isNotEmpty ? '$who — $reason' : who;
                            final req = m.submitNewParentRequest(
                              studentId: cid,
                              type: _earlyPickup
                                  ? 'Early Pickup'
                                  : 'Late Dropoff',
                              timeLabel: _formatTime(context, _requestTime),
                              pickupPersonSummary: pickupPersonSummary,
                            );
                            context.pushNamed(RequestSuccessfulWidget.routeName,
                                queryParameters: {'rid': req.id});
                          },
                          text: 'Submit Request',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56.0,
                            padding: EdgeInsets.all(8.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFFF7C530),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF0C3451),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 0.0,
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                      ),
                    ]
                        .divide(SizedBox(height: 16.0))
                        .addToStart(SizedBox(height: 16.0))
                        .addToEnd(SizedBox(height: 32.0)),
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
