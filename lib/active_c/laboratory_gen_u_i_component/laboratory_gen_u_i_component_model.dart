import '/active_c/concept_badge_component/concept_badge_component_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'laboratory_gen_u_i_component_widget.dart'
    show LaboratoryGenUIComponentWidget;
import 'package:flutter/material.dart';

class LaboratoryGenUIComponentModel
    extends FlutterFlowModel<LaboratoryGenUIComponentWidget> {
  ///  State fields for stateful widgets in this component.

  // Models for ConceptBadgeComponent dynamic component.
  late FlutterFlowDynamicModels<ConceptBadgeComponentModel>
      conceptBadgeComponentModels;

  @override
  void initState(BuildContext context) {
    conceptBadgeComponentModels =
        FlutterFlowDynamicModels(() => ConceptBadgeComponentModel());
  }

  @override
  void dispose() {
    conceptBadgeComponentModels.dispose();
  }
}
