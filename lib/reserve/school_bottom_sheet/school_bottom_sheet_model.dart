import '/flutter_flow/flutter_flow_util.dart';
import 'school_bottom_sheet_widget.dart' show SchoolBottomSheetWidget;
import 'package:flutter/material.dart';

class SchoolBottomSheetModel extends FlutterFlowModel<SchoolBottomSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for inputChatField widget.
  FocusNode? inputChatFieldFocusNode;
  TextEditingController? inputChatFieldTextController;
  String? Function(BuildContext, String?)?
      inputChatFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    inputChatFieldFocusNode?.dispose();
    inputChatFieldTextController?.dispose();
  }
}
