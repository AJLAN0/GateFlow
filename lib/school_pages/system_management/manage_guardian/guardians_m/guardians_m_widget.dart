import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../backend/supabase/models/db_models.dart';
import '../../../../data/mock_state.dart';
import 'guardians_m_model.dart';
export 'guardians_m_model.dart';

class GuardiansMWidget extends StatefulWidget {
  const GuardiansMWidget({super.key});

  static String routeName = 'GuardiansM';
  static String routePath = '/guardiansM';

  @override
  State<GuardiansMWidget> createState() => _GuardiansMWidgetState();
}

class _GuardiansMWidgetState extends State<GuardiansMWidget>
    with TickerProviderStateMixin {
  late GuardiansMModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GuardiansMModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
            'Manage Guardian ',
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment(0.0, 0),
                      child: TabBar(
                        labelColor: Color(0xFF0C3451),
                        unselectedLabelColor: Color(0x670C3451),
                        labelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                        unselectedLabelStyle: TextStyle(),
                        indicatorColor: Color(0xFF0C3451),
                        indicatorWeight: 3.0,
                        tabs: [
                          Tab(text: 'New '),
                          Tab(text: 'Approved '),
                        ],
                        controller: _model.tabBarController,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _model.tabBarController,
                        children: [
                          _guardianList(context, status: 'pending'),
                          _guardianList(context, status: 'approved'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guardianList(BuildContext context, {required String status}) {
    final mock = context.watch<MockState>();
    final items =
        mock.schoolGuardians.where((g) => g.status == status).toList();

    final isPending = status == 'pending';

    if (items.isEmpty) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        alignment: Alignment.center,
        child: Text(
          isPending
              ? 'No new guardian requests.'
              : 'No approved guardians yet.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return Container(
      color: FlutterFlowTheme.of(context).primaryBackground,
      child: ListView.builder(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final g = items[index];
          return Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
            child: InkWell(
              onTap: () => context.pushNamed(
                isPending
                    ? GuardianDetailsWidget.routeName
                    : ApprovedGDWidget.routeName,
                queryParameters: {'gid': g.id},
              ),
              borderRadius: BorderRadius.circular(12.0),
              child: _guardianCard(context, g, isPending),
            ),
          );
        },
      ),
    );
  }

  Widget _guardianCard(BuildContext context, DbGuardian g, bool isPending) {
    final subtitle = g.relationship?.isNotEmpty == true
        ? g.relationship!
        : (g.phone ?? 'Guardian');
    return Container(
      width: double.infinity,
      height: 90.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          )
        ],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.fullName,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                          ),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).labelMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isPending ? Color(0xFF8A94A6) : Color(0xFF22C55E),
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
