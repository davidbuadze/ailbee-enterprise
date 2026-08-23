import '/active_c/book_card_component/book_card_component_widget.dart';
import '/active_c/laboratory_gen_u_i_component/laboratory_gen_u_i_component_widget.dart';
import '/active_c/school_chat_component/school_chat_component_widget.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'school_module_model.dart';
export 'school_module_model.dart';

class SchoolModuleWidget extends StatefulWidget {
  const SchoolModuleWidget({super.key});

  static String routeName = 'SchoolModule';
  static String routePath = 'schoolModule';

  @override
  State<SchoolModuleWidget> createState() => _SchoolModuleWidgetState();
}

class _SchoolModuleWidgetState extends State<SchoolModuleWidget>
    with TickerProviderStateMixin {
  late SchoolModuleModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SchoolModuleModel());

    _model.schoolTabBarController = TabController(
      vsync: this,
      length: 4,
      initialIndex: min(
          valueOrDefault<int>(
            FFAppState().activeSchoolTab,
            0,
          ),
          3),
    )..addListener(() => safeSetState(() {}));

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: true)
          ..addListener(() => safeSetState(() {}));
    _model.inputChatFieldTextController ??= TextEditingController();
    _model.inputChatFieldFocusNode ??= FocusNode();

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
        title: 'SchoolModule',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          controller: _model.schoolTabBarController,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if (valueOrDefault<bool>(
                                          FFAppState().activeBookTitle !=
                                                  '',
                                          true,
                                        ))
                                          Expanded(
                                            child: Container(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              height: 48.0,
                                              decoration: BoxDecoration(),
                                              child: FFButtonWidget(
                                                onPressed: () async {
                                                  if (FFAppState()
                                                          .lastActivityType ==
                                                      'learning') {
                                                    context.goNamed(
                                                      PdfReaderPageWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'pdfUrl':
                                                            serializeParam(
                                                          FFAppState()
                                                              .activeBookContext,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  } else {
                                                    if (FFAppState()
                                                            .lastActivityType ==
                                                        'research') {
                                                      safeSetState(() {
                                                        _model
                                                            .schoolTabBarController!
                                                            .animateTo(
                                                          valueOrDefault<int>(
                                                            _model
                                                                .schoolTabBarCurrentIndex,
                                                            0,
                                                          ),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          curve: Curves.ease,
                                                        );
                                                      });
                                                    } else {
                                                      safeSetState(() {
                                                        _model
                                                            .schoolTabBarController!
                                                            .animateTo(
                                                          valueOrDefault<int>(
                                                            _model
                                                                .schoolTabBarPreviousIndex,
                                                            1,
                                                          ),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          curve: Curves.ease,
                                                        );
                                                      });
                                                    }
                                                  }
                                                },
                                                text: FFAppState()
                                                                .activeBookContext !=
                                                            ''
                                                    ? 'განაგრძე კითხვა'
                                                    : 'აირჩიე საცელმძღვანელო',
                                                options: FFButtonOptions(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          1.0,
                                                  height: 40.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 0.0, 0.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .tertiary,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                  elevation: 0.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                                showLoadingIndicator: false,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      color: Color(0x00000000),
                                      child: ExpandableNotifier(
                                        controller: _model
                                            .expandableExpandableController,
                                        child: ExpandablePanel(
                                          header: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                  child: Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'feqx2qvq' /* გეგმა, შეხსენება, კალენდარი */,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          collapsed: Container(),
                                          expanded: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              FlutterFlowCalendar(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                iconColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                weekFormat: false,
                                                weekStartsMonday: false,
                                                rowHeight: 48.0,
                                                onChange: (DateTimeRange?
                                                    newSelectedDate) {
                                                  safeSetState(() => _model
                                                          .calendarSelectedDay =
                                                      newSelectedDate);
                                                },
                                                titleStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleLargeFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleLargeIsCustom,
                                                        ),
                                                dayOfWeekStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                dateStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                selectedDateStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .titleSmallIsCustom,
                                                        ),
                                                inactiveDateStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelMediumIsCustom,
                                                        ),
                                                locale:
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                              ),
                                            ],
                                          ),
                                          theme: ExpandableThemeData(
                                            tapHeaderToExpand: true,
                                            tapBodyToExpand: true,
                                            tapBodyToCollapse: true,
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            hasIcon: true,
                                            expandIcon: Icons.arrow_drop_up,
                                            collapseIcon: Icons.arrow_drop_down,
                                            iconSize: 40.0,
                                            iconColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SafeArea(
                                      left: false,
                                      top: false,
                                      right: false,
                                      bottom: false,
                                      child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height: 10.0,
                                        decoration: BoxDecoration(),
                                      ),
                                    ),
                                    FlutterFlowCheckboxGroup(
                                      options: [
                                        FFLocalizations.of(context).getText(
                                          'ezez9gpi' /* მოვამზადო საკონტროლოს საკითხებ... */,
                                        ),
                                        FFLocalizations.of(context).getText(
                                          'rxo0sroc' /* ნინოს - ვაჟას პოეზიის გარჩევა */,
                                        ),
                                        FFLocalizations.of(context).getText(
                                          'bepdnxgg' /* კვირას ფეხბურთს ვთამაშობთ */,
                                        )
                                      ],
                                      onChanged: (val) => safeSetState(() =>
                                          _model.checkboxGroupValues = val),
                                      controller: _model
                                              .checkboxGroupValueController ??=
                                          FormFieldController<List<String>>(
                                        [],
                                      ),
                                      activeColor: Color(0x00000000),
                                      checkColor:
                                          FlutterFlowTheme.of(context).info,
                                      checkboxBorderColor: Color(0x00000000),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                      checkboxBorderRadius:
                                          BorderRadius.circular(4.0),
                                      initialized:
                                          _model.checkboxGroupValues != null,
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        for (int loop1Index = 0;
                                            loop1Index <
                                                _model.checkboxGroupValues!
                                                    .length;
                                            loop1Index++) {
                                          final currentLoop1Item = _model
                                              .checkboxGroupValues![loop1Index];
                                          _model.newEventId = await actions
                                              .addEventToSystemCalendar(
                                            currentLoop1Item,
                                            '',
                                            _model.calendarSelectedDay!.start,
                                            _model.calendarSelectedDay!.end,
                                          );

                                          var tasksRecordReference =
                                              TasksRecord.collection.doc();
                                          await tasksRecordReference
                                              .set(createTasksRecordData(
                                            title: currentLoop1Item,
                                            dueDate: _model
                                                .calendarSelectedDay?.start,
                                            isCompleted: false,
                                            calendarEventId: _model.newEventId,
                                            createdAt: getCurrentTimestamp,
                                            userRef: currentUserReference,
                                          ));
                                          _model.createDocument =
                                              TasksRecord.getDocumentFromData(
                                                  createTasksRecordData(
                                                    title: currentLoop1Item,
                                                    dueDate: _model
                                                        .calendarSelectedDay
                                                        ?.start,
                                                    isCompleted: false,
                                                    calendarEventId:
                                                        _model.newEventId,
                                                    createdAt:
                                                        getCurrentTimestamp,
                                                    userRef:
                                                        currentUserReference,
                                                  ),
                                                  tasksRecordReference);
                                        }

                                        safeSetState(() {});
                                      },
                                      text: FFLocalizations.of(context).getText(
                                        'zzsypaxi' /* აღნიშნულის შენახვა კალენდარში */,
                                      ),
                                      icon: Icon(
                                        Icons.check_box,
                                        size: 25.0,
                                      ),
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .secondary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 15.0),
                              child: wrapWithModel(
                                model: _model.schoolChatComponentModel,
                                updateCallback: () => safeSetState(() {}),
                                child: SchoolChatComponentWidget(),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FlutterFlowChoiceChips(
                                    options: [
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        '1cplxs8z' /* სასკოლო პროგრამა */,
                                      )),
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        'ccowawu4' /* კლასგარეშე საკითხავი */,
                                      ))
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.choiceCategoryValue =
                                            val?.firstOrNull),
                                    selectedChipStyle: ChipStyle(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                      iconColor:
                                          FlutterFlowTheme.of(context).info,
                                      iconSize: 0.0,
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    unselectedChipStyle: ChipStyle(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      iconSize: 0.0,
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    chipSpacing: 3.0,
                                    rowSpacing: 8.0,
                                    multiselect: false,
                                    initialized:
                                        _model.choiceCategoryValue != null,
                                    alignment: WrapAlignment.start,
                                    controller:
                                        _model.choiceCategoryValueController ??=
                                            FormFieldController<List<String>>(
                                      [
                                        FFLocalizations.of(context).getText(
                                          'z5giokjj' /* სასკოლო პროგრამა */,
                                        )
                                      ],
                                    ),
                                    wrapped: false,
                                  ),
                                  Expanded(
                                    child:
                                        StreamBuilder<List<AilbeeBooksRecord>>(
                                      stream: queryAilbeeBooksRecord(
                                        queryBuilder: (ailbeeBooksRecord) =>
                                            ailbeeBooksRecord
                                                .where(
                                                  'category_id',
                                                  isEqualTo:
                                                      valueOrDefault<String>(
                                                    _model.choiceCategoryValue,
                                                    'სასკოლო პროგრამა',
                                                  ),
                                                )
                                                .where(
                                                  'education_level_id',
                                                  isEqualTo:
                                                      valueOrDefault<String>(
                                                    _model.choiceClassValue,
                                                    '7',
                                                  ),
                                                )
                                                .where(
                                                  'academic_stage',
                                                  isEqualTo:
                                                      valueOrDefault<String>(
                                                    FFAppConstants
                                                        .PROCESSSCHOOL,
                                                    'school',
                                                  ),
                                                ),
                                        limit: 12,
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xFF120120),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        List<AilbeeBooksRecord>
                                            booksGridAilbeeBooksRecordList =
                                            snapshot.data!;

                                        return GridView.builder(
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10.0,
                                            mainAxisSpacing: 10.0,
                                            childAspectRatio: 0.9,
                                          ),
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount:
                                              booksGridAilbeeBooksRecordList
                                                  .length,
                                          itemBuilder:
                                              (context, booksGridIndex) {
                                            final booksGridAilbeeBooksRecord =
                                                booksGridAilbeeBooksRecordList[
                                                    booksGridIndex];
                                            return wrapWithModel(
                                              model: _model
                                                  .bookCardComponentModels
                                                  .getModel(
                                                booksGridAilbeeBooksRecord
                                                    .reference.id,
                                                booksGridIndex,
                                              ),
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: BookCardComponentWidget(
                                                key: Key(
                                                  'Key0ry_${booksGridAilbeeBooksRecord.reference.id}',
                                                ),
                                                title:
                                                    booksGridAilbeeBooksRecord
                                                        .title,
                                                grade:
                                                    booksGridAilbeeBooksRecord
                                                        .educationLevelId,
                                                subject:
                                                    booksGridAilbeeBooksRecord
                                                        .subjectId,
                                                pdfUrl:
                                                    booksGridAilbeeBooksRecord
                                                        .downloadUrl,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  FlutterFlowChoiceChips(
                                    options: [
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        'ct0muu9y' /* 7 */,
                                      )),
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        'u639tkbi' /* 8 */,
                                      )),
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        'gdyr7sqb' /* 9 */,
                                      )),
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        'ifsfjkmz' /* 10 */,
                                      )),
                                      ChipData(
                                          FFLocalizations.of(context).getText(
                                        'rxxsajj4' /* 11 */,
                                      ))
                                    ],
                                    onChanged: (val) async {
                                      safeSetState(() => _model
                                          .choiceClassValue = val?.firstOrNull);
                                      safeSetState(() {});
                                    },
                                    selectedChipStyle: ChipStyle(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .info,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                      iconColor:
                                          FlutterFlowTheme.of(context).info,
                                      iconSize: 16.0,
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    unselectedChipStyle: ChipStyle(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                      iconColor: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      iconSize: 16.0,
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    chipSpacing: 8.0,
                                    rowSpacing: 8.0,
                                    multiselect: false,
                                    initialized:
                                        _model.choiceClassValue != null,
                                    alignment: WrapAlignment.end,
                                    controller:
                                        _model.choiceClassValueController ??=
                                            FormFieldController<List<String>>(
                                      [
                                        valueOrDefault<String>(
                                          _model.schoolTabBarCurrentIndex
                                              .toString(),
                                          '7',
                                        )
                                      ],
                                    ),
                                    wrapped: true,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.labGenUIComponentModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: LaboratoryGenUIComponentWidget(),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    FlutterFlowChoiceChips(
                                      options: [
                                        ChipData(
                                            FFLocalizations.of(context).getText(
                                          'cxzma7x8' /* სად გამოიყენება ეს რეალურ სამყ... */,
                                        )),
                                        ChipData(
                                            FFLocalizations.of(context).getText(
                                          'isfeigl1' /* მითის განადგურება */,
                                        )),
                                        ChipData(
                                            FFLocalizations.of(context).getText(
                                          'scbbwpx9' /* საშინაო ექსპერიმენტი */,
                                        ))
                                      ],
                                      onChanged: (val) async {
                                        safeSetState(() =>
                                            _model.universalChipsValue =
                                                val?.firstOrNull);
                                        await action_blocks
                                            .sendSchoolLabMessage(
                                          context,
                                          userQuery: 'school_lab',
                                        );
                                      },
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              lineHeight: 1.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        iconColor:
                                            FlutterFlowTheme.of(context).info,
                                        iconSize: 0.0,
                                        elevation: 0.0,
                                        borderColor:
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              letterSpacing: 0.0,
                                              lineHeight: 1.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                        iconColor: Color(0x00000000),
                                        iconSize: 0.0,
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
                                      chipSpacing: 3.0,
                                      multiselect: false,
                                      alignment: WrapAlignment.center,
                                      controller: _model
                                              .universalChipsValueController ??=
                                          FormFieldController<List<String>>(
                                        [],
                                      ),
                                      wrapped: true,
                                    ),
                                    Divider(
                                      thickness: 2.0,
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            child: TextFormField(
                                              controller: _model
                                                  .inputChatFieldTextController,
                                              focusNode: _model
                                                  .inputChatFieldFocusNode,
                                              autofocus: false,
                                              enabled: false,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                isDense: false,
                                                alignLabelWithHint: true,
                                                hintText:
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                  'wecnay7w' /* ᲓᲐᲡᲕᲘᲗ ᲙᲘᲗᲮᲕᲔᲑᲘ ᲐᲛ ᲗᲔᲛᲔᲑᲘᲡ ᲒᲐᲡ... */,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary,
                                                    width: 3.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary,
                                                    width: 3.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 3.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 3.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                                filled: true,
                                                hoverColor:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                              textAlign: TextAlign.end,
                                              maxLines: 6,
                                              minLines: 1,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              enableInteractiveSelection: false,
                                              validator: _model
                                                  .inputChatFieldTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 70.0,
                                          child: VerticalDivider(
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 15.0),
                                          child: FlutterFlowIconButton(
                                            buttonSize: 40.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                            icon: Icon(
                                              Icons.send,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 25.0,
                                            ),
                                            onPressed: () async {
                                              await action_blocks
                                                  .sendSchoolLabMessage(
                                                context,
                                                userQuery: _model
                                                    .inputChatFieldTextController
                                                    .text,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 2.0,
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 12.0),
                                      child: Wrap(
                                        spacing: 0.0,
                                        runSpacing: 0.0,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        direction: Axis.horizontal,
                                        runAlignment: WrapAlignment.start,
                                        verticalDirection:
                                            VerticalDirection.down,
                                        clipBehavior: Clip.none,
                                        children: [
                                          FlutterFlowChoiceChips(
                                            options: (getJsonField(
                                              FFAppState().lastApiResponse,
                                              r'''$.subjects_involved''',
                                              true,
                                            ) as List?)!
                                                .map<String>(
                                                    (e) => e.toString())
                                                .toList()
                                                .cast<String>()
                                                .map((label) => ChipData(label))
                                                .toList(),
                                            onChanged: (val) async {
                                              safeSetState(() =>
                                                  _model.uniqueChipsValue =
                                                      val?.firstOrNull);
                                              await action_blocks
                                                  .sendSchoolLabMessage(
                                                context,
                                                userQuery: 'school_lab',
                                              );
                                            },
                                            selectedChipStyle: ChipStyle(
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .info,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              iconColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              iconSize: 16.0,
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            unselectedChipStyle: ChipStyle(
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              textStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                              iconColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              iconSize: 16.0,
                                              elevation: 0.0,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            chipSpacing: 8.0,
                                            rowSpacing: 8.0,
                                            multiselect: false,
                                            alignment: WrapAlignment.center,
                                            controller: _model
                                                    .uniqueChipsValueController ??=
                                                FormFieldController<
                                                    List<String>>(
                                              [],
                                            ),
                                            wrapped: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment(0.0, 0),
                        child: FlutterFlowButtonTabBar(
                          useToggleButtonStyle: false,
                          labelStyle: GoogleFonts.roboto(
                            color: Color(0x00000000),
                            fontSize: 0.0,
                          ),
                          unselectedLabelStyle: TextStyle(),
                          labelColor: FlutterFlowTheme.of(context).primaryText,
                          unselectedLabelColor:
                              FlutterFlowTheme.of(context).secondaryText,
                          backgroundColor:
                              FlutterFlowTheme.of(context).tertiary,
                          borderWidth: 0.0,
                          borderRadius: 0.0,
                          elevation: 0.0,
                          buttonMargin: EdgeInsetsDirectional.fromSTEB(
                              8.0, 0.0, 8.0, 0.0),
                          tabs: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 30.0,
                                ),
                                Tab(
                                  text: FFLocalizations.of(context).getText(
                                    'ps6trt1f' /*  */,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 30.0,
                                ),
                                Tab(
                                  text: FFLocalizations.of(context).getText(
                                    'tjdl69az' /*  */,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 25.0,
                                ),
                                Tab(
                                  text: FFLocalizations.of(context).getText(
                                    'ew28bkur' /*  */,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hub_outlined,
                                  size: 25.0,
                                ),
                                Tab(
                                  text: FFLocalizations.of(context).getText(
                                    'eh017yrj' /*  */,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          controller: _model.schoolTabBarController,
                          onTap: (i) async {
                            [
                              () async {},
                              () async {},
                              () async {},
                              () async {}
                            ][i]();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
