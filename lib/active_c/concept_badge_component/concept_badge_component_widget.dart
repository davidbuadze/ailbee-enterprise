import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'concept_badge_component_model.dart';
export 'concept_badge_component_model.dart';

/// learnedConcepts Item
class ConceptBadgeComponentWidget extends StatefulWidget {
  const ConceptBadgeComponentWidget({
    super.key,
    this.conceptTitle,
    String? subjectTag,
  }) : this.subjectTag = subjectTag ?? 'ბუნების ერთობა';

  final String? conceptTitle;
  final String subjectTag;

  @override
  State<ConceptBadgeComponentWidget> createState() =>
      _ConceptBadgeComponentWidgetState();
}

class _ConceptBadgeComponentWidgetState
    extends State<ConceptBadgeComponentWidget> {
  late ConceptBadgeComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConceptBadgeComponentModel());

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

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          FFAppState().activeBookContext = FFAppState()
              .schoolLabMessagesHistory
              .lastOrNull!
              .hasText()
              .toString();
          safeSetState(() {});

          context.goNamed(
            PdfReaderPageWidget.routeName,
            queryParameters: {
              'pdfUrl': serializeParam(
                FFAppState().activeBookContext,
                ParamType.String,
              ),
            }.withoutNulls,
          );
        },
        child: Container(
          width: double.infinity,
          height: 36.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondary,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.auto_awesome,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 16.0,
                ),
              ),
              Text(
                FFLocalizations.of(context).getText(
                  'lnovmjjn' /* conceptTitle */,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
