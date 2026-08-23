import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pdf_reader_page_widget.dart' show PdfReaderPageWidget;
import 'package:flutter/material.dart';

class PdfReaderPageModel extends FlutterFlowModel<PdfReaderPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // Stores action output result for [Backend Call - API (BookSearch)] action in ChoiceChips widget.
  ApiCallResponse? apiResulDynamictkq3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
