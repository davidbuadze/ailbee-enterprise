import '/active_c/book_card_component/book_card_component_widget.dart';
import '/active_c/laboratory_gen_u_i_component/laboratory_gen_u_i_component_widget.dart';
import '/active_c/school_chat_component/school_chat_component_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'school_module_widget.dart' show SchoolModuleWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class SchoolModuleModel extends FlutterFlowModel<SchoolModuleWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for School_TabBar widget.
  TabController? schoolTabBarController;
  int get schoolTabBarCurrentIndex =>
      schoolTabBarController != null ? schoolTabBarController!.index : 0;
  int get schoolTabBarPreviousIndex => schoolTabBarController != null
      ? schoolTabBarController!.previousIndex
      : 0;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;
  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController;
  List<String>? get checkboxGroupValues => checkboxGroupValueController?.value;
  set checkboxGroupValues(List<String>? v) =>
      checkboxGroupValueController?.value = v;

  // Stores action output result for [Custom Action - addEventToSystemCalendar] action in Button widget.
  String? newEventId;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  TasksRecord? createDocument;
  // Model for SchoolChatComponent component.
  late SchoolChatComponentModel schoolChatComponentModel;
  // State field(s) for ChoiceCategory widget.
  FormFieldController<List<String>>? choiceCategoryValueController;
  String? get choiceCategoryValue =>
      choiceCategoryValueController?.value?.firstOrNull;
  set choiceCategoryValue(String? val) =>
      choiceCategoryValueController?.value = val != null ? [val] : [];
  // Models for BookCardComponent dynamic component.
  late FlutterFlowDynamicModels<BookCardComponentModel> bookCardComponentModels;
  // State field(s) for ChoiceClass widget.
  FormFieldController<List<String>>? choiceClassValueController;
  String? get choiceClassValue =>
      choiceClassValueController?.value?.firstOrNull;
  set choiceClassValue(String? val) =>
      choiceClassValueController?.value = val != null ? [val] : [];
  // Model for LabGenUIComponent.
  late LaboratoryGenUIComponentModel labGenUIComponentModel;
  // State field(s) for UniversalChips widget.
  FormFieldController<List<String>>? universalChipsValueController;
  String? get universalChipsValue =>
      universalChipsValueController?.value?.firstOrNull;
  set universalChipsValue(String? val) =>
      universalChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for inputChatField widget.
  FocusNode? inputChatFieldFocusNode;
  TextEditingController? inputChatFieldTextController;
  String? Function(BuildContext, String?)?
      inputChatFieldTextControllerValidator;
  // State field(s) for UniqueChips widget.
  FormFieldController<List<String>>? uniqueChipsValueController;
  String? get uniqueChipsValue =>
      uniqueChipsValueController?.value?.firstOrNull;
  set uniqueChipsValue(String? val) =>
      uniqueChipsValueController?.value = val != null ? [val] : [];

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
    schoolChatComponentModel =
        createModel(context, () => SchoolChatComponentModel());
    bookCardComponentModels =
        FlutterFlowDynamicModels(() => BookCardComponentModel());
    labGenUIComponentModel =
        createModel(context, () => LaboratoryGenUIComponentModel());
  }

  @override
  void dispose() {
    schoolTabBarController?.dispose();
    expandableExpandableController.dispose();
    schoolChatComponentModel.dispose();
    bookCardComponentModels.dispose();
    labGenUIComponentModel.dispose();
    inputChatFieldFocusNode?.dispose();
    inputChatFieldTextController?.dispose();
  }
}
