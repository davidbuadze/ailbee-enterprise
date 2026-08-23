import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'custom_navigation_menu_model.dart';
export 'custom_navigation_menu_model.dart';

class CustomNavigationMenuWidget extends StatefulWidget {
  const CustomNavigationMenuWidget({
    super.key,
    this.activeTab,
  });

  final int? activeTab;

  @override
  State<CustomNavigationMenuWidget> createState() =>
      _CustomNavigationMenuWidgetState();
}

class _CustomNavigationMenuWidgetState
    extends State<CustomNavigationMenuWidget> {
  late CustomNavigationMenuModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomNavigationMenuModel());

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
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!FFAppState().isOfflineMode)
              Expanded(
                child: FlutterFlowIconButton(
                  borderColor: FlutterFlowTheme.of(context).accent3,
                  borderRadius: 8.0,
                  buttonSize: 65.0,
                  fillColor: FlutterFlowTheme.of(context).tertiary,
                  icon: Icon(
                    Icons.wifi,
                    color: FlutterFlowTheme.of(context).secondary,
                    size: 48.0,
                  ),
                  onPressed: () async {
                    FFAppState().isOfflineMode =
                        !(FFAppState().isOfflineMode ?? true);
                    safeSetState(() {});
                  },
                ),
              ),
            if (FFAppState().isOfflineMode)
              Expanded(
                child: FlutterFlowIconButton(
                  borderColor: FlutterFlowTheme.of(context).accent3,
                  borderRadius: 8.0,
                  buttonSize: 65.0,
                  fillColor: FlutterFlowTheme.of(context).secondaryText,
                  icon: Icon(
                    Icons.wifi_off,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 48.0,
                  ),
                  onPressed: () async {
                    FFAppState().isOfflineMode =
                        !(FFAppState().isOfflineMode ?? true);
                    safeSetState(() {});
                  },
                ),
              ),
            Expanded(
              child: FlutterFlowIconButton(
                borderColor: FlutterFlowTheme.of(context).accent3,
                borderRadius: 8.0,
                buttonSize: 65.0,
                icon: FaIcon(
                  FontAwesomeIcons.react,
                  color: widget.activeTab == 3
                      ? FlutterFlowTheme.of(context).tertiary
                      : FlutterFlowTheme.of(context).primaryBackground,
                  size: 48.0,
                ),
                onPressed: () async {
                  context.goNamed(DashboardWidget.routeName);
                },
              ),
            ),
            Expanded(
              child: FlutterFlowIconButton(
                borderColor: FlutterFlowTheme.of(context).accent3,
                borderRadius: 8.0,
                buttonSize: 65.0,
                icon: FaIcon(
                  FontAwesomeIcons.react,
                  color: widget.activeTab == 3
                      ? FlutterFlowTheme.of(context).tertiary
                      : FlutterFlowTheme.of(context).primaryBackground,
                  size: 48.0,
                ),
                onPressed: () async {
                  context.goNamed(DashboardWidget.routeName);
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [],
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [],
        ),
      ],
    );
  }
}
