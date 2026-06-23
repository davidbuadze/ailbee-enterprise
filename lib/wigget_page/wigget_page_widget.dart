import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'wigget_page_model.dart';
export 'wigget_page_model.dart';

class WiggetPageWidget extends StatefulWidget {
  const WiggetPageWidget({super.key});

  static String routeName = 'WiggetPage';
  static String routePath = 'Dashboard';

  @override
  State<WiggetPageWidget> createState() => _WiggetPageWidgetState();
}

class _WiggetPageWidgetState extends State<WiggetPageWidget> {
  late WiggetPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WiggetPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                // On/Off
                FFAppState().selectedModel = 'gemma';
                safeSetState(() {});
              },
              child: Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 1.0,
                child: custom_widgets.AilbeePlanetaryDashboard(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
