import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../data/mock_state.dart';
import '../../shared/gateflow_colors.dart';
import '../request_pic_dro/request_pic_dro_widget.dart';
import 'select_child_for_request_model.dart';

export 'select_child_for_request_model.dart';

/// Mandatory step before composing a pickup/dismissal request.
class SelectChildForRequestWidget extends StatefulWidget {
  const SelectChildForRequestWidget({super.key});

  static String routeName = 'SelectChildForRequest';
  static String routePath = '/selectChildForRequest';

  @override
  State<SelectChildForRequestWidget> createState() =>
      _SelectChildForRequestWidgetState();
}

class _SelectChildForRequestWidgetState
    extends State<SelectChildForRequestWidget> {
  late SelectChildForRequestModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectChildForRequestModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = context.watch<MockState>();
    final children = mock.parentDemoChildren;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GateFlowColors.surface,
        appBar: AppBar(
          backgroundColor: GateFlowColors.brandPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            'Select child',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: children.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text(
                'Choose who this request is for.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: GateFlowColors.textSecondary,
                ),
              );
            }
            final c = children[i - 1];
            final isBus = c.transport == DemoChildTransport.bus;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.pushNamed(
                  RequestPicDroWidget.routeName,
                  queryParameters: {'cid': c.id},
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GateFlowColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBus
                            ? Icons.directions_bus_rounded
                            : Icons.directions_car_rounded,
                        color: isBus
                            ? GateFlowColors.success
                            : GateFlowColors.info,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${c.grade} · ${isBus ? 'School bus' : 'Private car'}',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: GateFlowColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: GateFlowColors.textTertiary),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
