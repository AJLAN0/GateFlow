import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'time_request_widget.dart' show TimeRequestWidget;

class TimeRequestModel extends FlutterFlowModel<TimeRequestWidget> {
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
