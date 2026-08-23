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
    String? agentId = 'research_expert_agent',
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
  "prompt": "\$.researchContext",
  "agent_id": "\$.agent_id",
  "conversation_id": "\$.conversation_id",
  "message": "\$.userMessage",
  "query": "\$.targetQuery"
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

  dynamic executionmode(dynamic response) => getJsonField(
        response,
        r'''$.execution_mode''',
      );
}

class BookSearchCall {
  Future<ApiCallResponse> call({
    String? queryVariable = '',
    String? agentId = 'school_public_agent',
    String? conversationIdVariable = '',
    String? bookContextVariable = 'none',
    List<String>? learnedTopicsList,
    List<String>? learnedConceptsList,
    String? idToken = '',
  }) async {
    final baseUrl = AgentsCallGroupAPIGroup.getBaseUrl(
      idToken: idToken,
    );
    final learnedTopics = _serializeList(learnedTopicsList);
    final learnedConcepts = _serializeList(learnedConceptsList);

    final ffApiRequestBody = '''
{
  "query": "\$.query_variable",
  "agent_id": "\$.ailbee-enterprise-knowledg_1779121464248",
  "conversation_id": "\$.conversation_id_variable",
  "book_context": "\$.book_context_variable",
  "learned_topics": "\$.learned_topics",
  "learned_concepts": "\$.learned_concepts"
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

  String? conversationid(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.conversation_id''',
      ));
  List? citations(dynamic response) => getJsonField(
        response,
        r'''$.citations''',
        true,
      ) as List?;
  String? replyquote(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reply.quote''',
      ));
  String? replybaseanswer(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reply.base_answer''',
      ));
  String? replyaiexplanation(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.reply.ai_explanation''',
      ));
  String? replyquestion(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reply.question''',
      ));
  List<String>? replysuggestedchips(dynamic response) => (getJsonField(
        response,
        r'''$.reply.suggested_chips''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
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
