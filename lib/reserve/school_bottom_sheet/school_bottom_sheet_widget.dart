import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'school_bottom_sheet_model.dart';
export 'school_bottom_sheet_model.dart';

class SchoolBottomSheetWidget extends StatefulWidget {
  const SchoolBottomSheetWidget({super.key});

  @override
  State<SchoolBottomSheetWidget> createState() =>
      _SchoolBottomSheetWidgetState();
}

class _SchoolBottomSheetWidgetState extends State<SchoolBottomSheetWidget> {
  late SchoolBottomSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SchoolBottomSheetModel());

    _model.inputChatFieldTextController ??= TextEditingController();
    _model.inputChatFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.inputChatFieldTextController?.text =
              FFLocalizations.of(context).getText(
            '2h9jgtdm' /* ᲒᲐᲛᲝᲧᲐᲕᲘᲗ ᲢᲔᲥᲡᲢᲘ ᲐᲜ ᲓᲐᲡᲕᲘᲗ ᲨᲔᲙ... */,
          );
        }));
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
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
          child: SafeArea(
            left: false,
            top: false,
            right: false,
            bottom: false,
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).tertiary,
                borderRadius: BorderRadius.circular(2.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).tertiary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final chatMessagesList =
                          FFAppState().schoolChatMessagesHistory.toList();

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        primary: false,
                        scrollDirection: Axis.vertical,
                        itemCount: chatMessagesList.length,
                        itemBuilder: (context, chatMessagesListIndex) {
                          final chatMessagesListItem =
                              chatMessagesList[chatMessagesListIndex];
                          return Container(
                            decoration: BoxDecoration(),
                            child: Text(
                              chatMessagesListItem.text,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.roboto(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _model.inputChatFieldTextController,
                          focusNode: _model.inputChatFieldFocusNode,
                          autofocus: false,
                          enabled: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: false,
                            hintText: FFLocalizations.of(context).getText(
                              'o7a6v3cs' /* ᲒᲐᲛᲝᲧᲐᲕᲘᲗ ᲢᲔᲥᲡᲢᲘ ᲐᲜ ᲓᲐᲡᲕᲘᲗ ᲨᲔᲙ... */,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: true,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelSmallFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelSmallIsCustom,
                              ),
                          textAlign: TextAlign.end,
                          maxLines: 5,
                          minLines: 1,
                          cursorColor: FlutterFlowTheme.of(context).primaryText,
                          enableInteractiveSelection: false,
                          validator: _model
                              .inputChatFieldTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      FlutterFlowIconButton(
                        buttonSize: 40.0,
                        fillColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        icon: Icon(
                          Icons.send,
                          color: FlutterFlowTheme.of(context).info,
                        ),
                        onPressed: () {
                          print('Send_Request pressed ...');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
