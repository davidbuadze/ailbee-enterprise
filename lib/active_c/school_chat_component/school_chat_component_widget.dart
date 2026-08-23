import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'school_chat_component_model.dart';
export 'school_chat_component_model.dart';

class SchoolChatComponentWidget extends StatefulWidget {
  const SchoolChatComponentWidget({super.key});

  @override
  State<SchoolChatComponentWidget> createState() =>
      _SchoolChatComponentWidgetState();
}

class _SchoolChatComponentWidgetState extends State<SchoolChatComponentWidget> {
  late SchoolChatComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SchoolChatComponentModel());

    _model.inputChatFieldTextController ??= TextEditingController();
    _model.inputChatFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.inputChatFieldTextController?.text =
              FFLocalizations.of(context).getText(
            'ctm5mo7m' /* ᲐᲥ ᲨᲔᲔᲮᲔᲗ ᲓᲐ ᲩᲐᲬᲔᲠᲔᲗ ᲗᲥᲕᲔᲜᲘ ᲨᲔ... */,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Builder(
            builder: (context) {
              final schoolChatMessagesList =
                  FFAppState().schoolChatMessagesHistory.toList();

              return ListView.builder(
                padding: EdgeInsets.zero,
                primary: false,
                scrollDirection: Axis.vertical,
                itemCount: schoolChatMessagesList.length,
                itemBuilder: (context, schoolChatMessagesListIndex) {
                  final schoolChatMessagesListItem =
                      schoolChatMessagesList[schoolChatMessagesListIndex];
                  return Container(
                    decoration: BoxDecoration(),
                    child: Text(
                      schoolChatMessagesListItem.text,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional(-1.0, 1.0),
                  child: TextFormField(
                    controller: _model.inputChatFieldTextController,
                    focusNode: _model.inputChatFieldFocusNode,
                    autofocus: false,
                    enabled: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      isDense: false,
                      alignLabelWithHint: true,
                      hintText: FFLocalizations.of(context).getText(
                        'rytn4s1x' /* ᲐᲥ ᲨᲔᲔᲮᲔᲗ ᲓᲐ ᲩᲐᲬᲔᲠᲔᲗ ᲗᲥᲕᲔᲜᲘ ᲨᲔ... */,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelSmallFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelSmallIsCustom,
                        ),
                    textAlign: TextAlign.end,
                    maxLines: 6,
                    minLines: 1,
                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                    enableInteractiveSelection: false,
                    validator: _model.inputChatFieldTextControllerValidator
                        .asValidator(context),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1.0, 1.0),
                child: FlutterFlowIconButton(
                  buttonSize: 48.0,
                  fillColor: FlutterFlowTheme.of(context).primaryBackground,
                  icon: Icon(
                    Icons.send,
                    color: FlutterFlowTheme.of(context).info,
                  ),
                  onPressed: () async {
                    await action_blocks.sendSchoolMessage(
                      context,
                      userQuery: _model.inputChatFieldTextController.text,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
