import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start AgentsCallGroupAPI Group Code

class AgentsCallGroupAPIGroup {
  static String getBaseUrl({
    String? idToken = '',
  }) =>
      'https://ailbee-enterprise-hub-991527374957.us-central1.run.app';
  static Map<String, String> headers = {
    'Authorization': 'Bearer [id_token]',
    'Content-Type': 'application/json',
  };
  static ResearchConverseCall researchConverseCall = ResearchConverseCall();
  static BookSearchCall bookSearchCall = BookSearchCall();
}

class ResearchConverseCall {
  Future<ApiCallResponse> call({
    String? researchContext = '',
    String? agentId = '',
    String? conversationId = '',
    String? userMessage = '',
    String? targetQuery = '',
    String? idToken = '',
  }) async {
    final baseUrl = AgentsCallGroupAPIGroup.getBaseUrl(
      idToken: idToken,
    );

    final ffApiRequestBody = '''
{
  "prompt": "[researchContext]",
  "agent_id": "${agentId}",
  "conversation_id": "[conversation_id]",
  "message": "[userMessage]",
  "query": "[targetQuery]"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'ResearchConverse',
      apiUrl: '${baseUrl}/api/v3/chat/converse',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${idToken}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BookSearchCall {
  Future<ApiCallResponse> call({
    String? query = '',
    String? agentId = '',
    String? conversationId = '',
    String? idToken = '',
  }) async {
    final baseUrl = AgentsCallGroupAPIGroup.getBaseUrl(
      idToken: idToken,
    );

    final ffApiRequestBody = '''
{
  "query": "[query]",
  "agent_id": "agent_id",
  "conversation_id": "[conversation_id]"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'BookSearch',
      apiUrl: '${baseUrl}/api/v3/search/converse',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${idToken}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic reply(dynamic response) => getJsonField(
        response,
        r'''$.reply''',
      );
  dynamic conversationid(dynamic response) => getJsonField(
        response,
        r'''$.conversation_id''',
      );
  List? citations(dynamic response) => getJsonField(
        response,
        r'''$.citations''',
        true,
      ) as List?;
}

/// End AgentsCallGroupAPI Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
