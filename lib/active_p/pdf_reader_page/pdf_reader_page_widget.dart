import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_pdf_viewer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/reserve/school_bottom_sheet/school_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pdf_reader_page_model.dart';
export 'pdf_reader_page_model.dart';

class PdfReaderPageWidget extends StatefulWidget {
  const PdfReaderPageWidget({
    super.key,
    required this.pdfUrl,
  });

  final String? pdfUrl;

  static String routeName = 'PdfReaderPage';
  static String routePath = 'pdfReaderPage';

  @override
  State<PdfReaderPageWidget> createState() => _PdfReaderPageWidgetState();
}

class _PdfReaderPageWidgetState extends State<PdfReaderPageWidget> {
  late PdfReaderPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PdfReaderPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
        title: 'PdfReaderPage',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            left: false,
            top: false,
            right: false,
            bottom: false,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: FlutterFlowPdfViewer(
                              networkPath: valueOrDefault<String>(
                                widget.pdfUrl,
                                'https://pdfobject.com/pdf/sample.pdf',
                              ),
                              horizontalScroll: false,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 88.0, 0.0, 0.0),
                          child: Container(
                            width: 70.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: FFButtonWidget(
                              onPressed: () async {
                                if ((FFAppState().activeBookContext != '') &&
                                    (FFAppState().activeBookContext !=
                                        valueOrDefault<String>(
                                          'none',
                                          'none',
                                        ))) {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: Container(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.7,
                                          child: SchoolBottomSheetWidget(),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                } else {
                                  FFAppState().activeBookContext =
                                      widget.pdfUrl!;
                                  safeSetState(() {});
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: SchoolBottomSheetWidget(),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                }
                              },
                              text: FFLocalizations.of(context).getText(
                                's8krifrk' /* AI */,
                              ),
                              icon: Icon(
                                Icons.auto_awesome,
                                size: 40.0,
                              ),
                              options: FFButtonOptions(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconAlignment: IconAlignment.start,
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).tertiary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleLargeFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleLargeIsCustom,
                                    ),
                                elevation: 8.0,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0),
                                  bottomLeft: Radius.circular(30.0),
                                ),
                              ),
                              showLoadingIndicator: false,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: Wrap(
                          spacing: 0.0,
                          runSpacing: 0.0,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          direction: Axis.horizontal,
                          runAlignment: WrapAlignment.end,
                          verticalDirection: VerticalDirection.down,
                          clipBehavior: Clip.none,
                          children: [
                            FlutterFlowChoiceChips(
                              options: FFAppState()
                                  .learnedTopics
                                  .map((label) => ChipData(label))
                                  .toList(),
                              onChanged: (val) async {
                                safeSetState(() =>
                                    _model.choiceChipsValue = val?.firstOrNull);
                                _model.apiResulDynamictkq3 =
                                    await AgentsCallGroupAPIGroup.bookSearchCall
                                        .call(
                                  queryVariable: _model.choiceChipsValue,
                                  conversationIdVariable:
                                      FFAppState().currentConversationId,
                                  bookContextVariable:
                                      FFAppState().activeBookContext,
                                  learnedTopicsList: FFAppState().learnedTopics,
                                );

                                if (FFAppState()
                                    .learnedTopics
                                    .contains(FFAppState().activeBookContext)) {
                                  FFAppState().currentConversationId =
                                      getJsonField(
                                    (_model.apiResulDynamictkq3?.jsonBody ??
                                        ''),
                                    r'''$.conversation_id''',
                                  ).toString();
                                  FFAppState().lastApiResponse = getJsonField(
                                    (_model.apiResulDynamictkq3?.jsonBody ??
                                        ''),
                                    r'''$''',
                                  );
                                  safeSetState(() {});
                                } else {
                                  FFAppState().addToLearnedTopics(
                                      FFAppState().activeBookContext);
                                  safeSetState(() {});
                                }

                                safeSetState(() {});
                              },
                              selectedChipStyle: ChipStyle(
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context).info,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                                iconColor: FlutterFlowTheme.of(context).info,
                                iconSize: 0.0,
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              unselectedChipStyle: ChipStyle(
                                backgroundColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                                iconColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                                iconSize: 0.0,
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              chipSpacing: 3.0,
                              rowSpacing: 3.0,
                              multiselect: false,
                              alignment: WrapAlignment.center,
                              controller: _model.choiceChipsValueController ??=
                                  FormFieldController<List<String>>(
                                [],
                              ),
                              wrapped: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 90.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              12.0, 0.0, 0.0, 0.0),
                          child: FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30.0,
                            borderWidth: 1.0,
                            buttonSize: 50.0,
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            onPressed: () async {
                              FFAppState().activeBookTitle =
                                  valueOrDefault<String>(
                                'none',
                                'none',
                              );
                              FFAppState().activeBookContext =
                                  valueOrDefault<String>(
                                'none',
                                'none',
                              );
                              safeSetState(() {});
                              context.pop();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              4.0, 0.0, 0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'qn60dl7p' /* Back */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineMediumFamily,
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineMediumIsCustom,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
