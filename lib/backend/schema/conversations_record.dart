import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ConversationsRecord extends FirestoreRecord {
  ConversationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "conversation_id" field.
  String? _conversationId;
  String get conversationId => _conversationId ?? '';
  bool hasConversationId() => _conversationId != null;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "agent_id" field.
  String? _agentId;
  String get agentId => _agentId ?? '';
  bool hasAgentId() => _agentId != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "last_updated" field.
  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;
  bool hasLastUpdated() => _lastUpdated != null;

  void _initializeFields() {
    _conversationId = snapshotData['conversation_id'] as String?;
    _userId = snapshotData['user_id'] as String?;
    _agentId = snapshotData['agent_id'] as String?;
    _title = snapshotData['title'] as String?;
    _lastUpdated = snapshotData['last_updated'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'ailbee')
          .collection('conversations');

  static Stream<ConversationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ConversationsRecord.fromSnapshot(s));

  static Future<ConversationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ConversationsRecord.fromSnapshot(s));

  static ConversationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ConversationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ConversationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ConversationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ConversationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ConversationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createConversationsRecordData({
  String? conversationId,
  String? userId,
  String? agentId,
  String? title,
  DateTime? lastUpdated,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'conversation_id': conversationId,
      'user_id': userId,
      'agent_id': agentId,
      'title': title,
      'last_updated': lastUpdated,
    }.withoutNulls,
  );

  return firestoreData;
}

class ConversationsRecordDocumentEquality
    implements Equality<ConversationsRecord> {
  const ConversationsRecordDocumentEquality();

  @override
  bool equals(ConversationsRecord? e1, ConversationsRecord? e2) {
    return e1?.conversationId == e2?.conversationId &&
        e1?.userId == e2?.userId &&
        e1?.agentId == e2?.agentId &&
        e1?.title == e2?.title &&
        e1?.lastUpdated == e2?.lastUpdated;
  }

  @override
  int hash(ConversationsRecord? e) => const ListEquality().hash(
      [e?.conversationId, e?.userId, e?.agentId, e?.title, e?.lastUpdated]);

  @override
  bool isValidKey(Object? o) => o is ConversationsRecord;
}
