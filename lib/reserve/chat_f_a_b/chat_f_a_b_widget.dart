import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'chat_f_a_b_model.dart';
export 'chat_f_a_b_model.dart';

class ChatFABWidget extends StatefulWidget {
  const ChatFABWidget({super.key});

  @override
  State<ChatFABWidget> createState() => _ChatFABWidgetState();
}

class _ChatFABWidgetState extends State<ChatFABWidget> {
  late ChatFABModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatFABModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(1.0, 0.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          width: 80.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary,
          ),
          child: FFButtonWidget(
            onPressed: () {
              print('Button pressed ...');
            },
            text: FFLocalizations.of(context).getText(
              'zgtj2y8o' /*  */,
            ),
            icon: Icon(
              Icons.auto_awesome,
              size: 40.0,
            ),
            options: FFButtonOptions(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconAlignment: IconAlignment.start,
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).tertiary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                    color: Colors.white,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleSmallIsCustom,
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
    );
  }
}
