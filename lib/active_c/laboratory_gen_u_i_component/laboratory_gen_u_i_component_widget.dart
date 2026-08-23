import '/active_c/concept_badge_component/concept_badge_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'laboratory_gen_u_i_component_model.dart';
export 'laboratory_gen_u_i_component_model.dart';

class LaboratoryGenUIComponentWidget extends StatefulWidget {
  const LaboratoryGenUIComponentWidget({super.key});

  @override
  State<LaboratoryGenUIComponentWidget> createState() =>
      _LaboratoryGenUIComponentWidgetState();
}

class _LaboratoryGenUIComponentWidgetState
    extends State<LaboratoryGenUIComponentWidget> {
  late LaboratoryGenUIComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LaboratoryGenUIComponentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          FFLocalizations.of(context).getText(
            '4t9dkhvf' /* დღის თემები */,
          ),
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final researchMessages = FFAppState()
                  .schoolLabMessagesHistory
                  .toList()
                  .take(500)
                  .toList();

              return ListView.builder(
                padding: EdgeInsets.zero,
                primary: false,
                scrollDirection: Axis.vertical,
                itemCount: researchMessages.length,
                itemBuilder: (context, researchMessagesIndex) {
                  final researchMessagesItem =
                      researchMessages[researchMessagesIndex];
                  return Container(
                    child: Container(
                      width: double.infinity,
                      color: Color(0x00000000),
                      child: ExpandableNotifier(
                        initialExpanded: false,
                        child: ExpandablePanel(
                          header: Text(
                            valueOrDefault<String>(
                              FFAppState()
                                  .schoolLabMessagesHistory
                                  .lastOrNull
                                  ?.hasText()
                                  .toString(),
                              'თემის სათაური',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                          collapsed: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                valueOrDefault<String>(
                                  FFAppState()
                                      .schoolLabMessagesHistory
                                      .lastOrNull
                                      ?.hasText()
                                      .toString(),
                                  'შემოკლებული ტექსტი ',
                                ),
                                maxLines: 1,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          expanded: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                valueOrDefault<String>(
                                  FFAppState()
                                      .schoolLabMessagesHistory
                                      .lastOrNull
                                      ?.hasText()
                                      .toString(),
                                  'სრული ტექსტი',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                              wrapWithModel(
                                model:
                                    _model.conceptBadgeComponentModels.getModel(
                                  FFAppState()
                                      .schoolLabMessagesHistory
                                      .lastOrNull!
                                      .hasText()
                                      .toString(),
                                  researchMessagesIndex,
                                ),
                                updateCallback: () => safeSetState(() {}),
                                child: ConceptBadgeComponentWidget(
                                  key: Key(
                                    'Keyx6u_${FFAppState().schoolLabMessagesHistory.lastOrNull!.hasText().toString()}',
                                  ),
                                  conceptTitle: FFAppState()
                                      .schoolLabMessagesHistory
                                      .lastOrNull
                                      ?.hasText()
                                      .toString(),
                                  subjectTag: FFAppState().currentSubject,
                                ),
                              ),
                            ],
                          ),
                          theme: ExpandableThemeData(
                            tapHeaderToExpand: true,
                            tapBodyToExpand: false,
                            tapBodyToCollapse: false,
                            headerAlignment: ExpandablePanelHeaderAlignment.top,
                            hasIcon: true,
                            expandIcon: Icons.keyboard_arrow_down,
                            collapseIcon: Icons.keyboard_arrow_up,
                            iconSize: 25.0,
                            iconColor: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
