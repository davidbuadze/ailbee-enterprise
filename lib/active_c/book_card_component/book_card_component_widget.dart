import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'book_card_component_model.dart';
export 'book_card_component_model.dart';

/// bookCard
class BookCardComponentWidget extends StatefulWidget {
  const BookCardComponentWidget({
    super.key,
    required this.title,
    this.grade,
    this.subject,
    this.pdfUrl,
  });

  final String? title;
  final String? grade;
  final String? subject;
  final String? pdfUrl;

  @override
  State<BookCardComponentWidget> createState() =>
      _BookCardComponentWidgetState();
}

class _BookCardComponentWidgetState extends State<BookCardComponentWidget> {
  late BookCardComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BookCardComponentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          FFAppState().activeBookContext = widget.title!;
          FFAppState().currentConversationId = 'new';
          safeSetState(() {});

          context.goNamed(
            PdfReaderPageWidget.routeName,
            queryParameters: {
              'pdfUrl': serializeParam(
                widget.pdfUrl,
                ParamType.String,
              ),
            }.withoutNulls,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: 250.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      widget.title,
                      'ფიზიკა',
                    ),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).headlineLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).headlineLargeFamily,
                          fontSize: 15.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .headlineLargeIsCustom,
                        ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: 250.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      '${widget.grade}კლასი',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineLarge.override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .headlineLargeFamily,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .headlineLargeIsCustom,
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
