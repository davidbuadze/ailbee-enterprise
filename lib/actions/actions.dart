import '/auth/base_auth_user_provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';

Future sendSchoolMessage(
  BuildContext context, {
  String? userQuery,
}) async {
  dynamic dispatcherResult;

  dispatcherResult = await actions.dispatcher(
    userQuery!,
    FFAppConstants.USERGRADEANONYMOUS,
    FFAppConstants.PROCESSSCHOOL,
    FFAppState().schoolChatMessagesHistory.toList(),
    true,
    true,
    'low',
    FFAppState().currentConversationId != '',
  );
  FFAppState().addToSchoolChatMessagesHistory(ChatMessageStruct(
    sender: '\"assistant\"',
    text: getJsonField(
      dispatcherResult,
      r'''$.answer''',
    ).toString(),
  ));
  FFAppState().lastApiResponse = dispatcherResult!;
}

Future sendResearchMessage(
  BuildContext context, {
  String? userQuery,
}) async {
  dynamic dispatcherResult;

  dispatcherResult = await actions.dispatcher(
    userQuery!,
    loggedIn.toString(),
    FFAppConstants.PROCESSRESEARCH,
    FFAppState().researchMessagesHistory.toList(),
    true,
    true,
    'low',
    FFAppState().currentConversationId != '',
  );
  FFAppState().addToResearchMessagesHistory(ChatMessageStruct(
    sender: '\"assistant\"',
    text: getJsonField(
      dispatcherResult,
      r'''$.answer''',
    ).toString(),
  ));
  FFAppState().lastApiResponse = dispatcherResult!;
}

Future sendSchoolLabMessage(
  BuildContext context, {
  String? userQuery,
}) async {
  dynamic dispatcherResult;

  dispatcherResult = await actions.dispatcher(
    userQuery!,
    FFAppConstants.USERGRADEANONYMOUS,
    FFAppConstants.PROCESSSCHOOLLAB,
    FFAppState().schoolLabMessagesHistory.toList(),
    true,
    true,
    'low',
    FFAppState().currentConversationId != '',
  );
  FFAppState().addToSchoolLabMessagesHistory(ChatMessageStruct(
    sender: '\"assistant\"',
    text: getJsonField(
      dispatcherResult,
      r'''$.answer''',
    ).toString(),
  ));
}
