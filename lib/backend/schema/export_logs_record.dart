import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ExportLogsRecord extends FirestoreRecord {
  ExportLogsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'ailbee')
          .collection('export_logs');

  static Stream<ExportLogsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ExportLogsRecord.fromSnapshot(s));

  static Future<ExportLogsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ExportLogsRecord.fromSnapshot(s));

  static ExportLogsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ExportLogsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ExportLogsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ExportLogsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ExportLogsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ExportLogsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createExportLogsRecordData({
  String? userId,
  DateTime? timestamp,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'timestamp': timestamp,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class ExportLogsRecordDocumentEquality implements Equality<ExportLogsRecord> {
  const ExportLogsRecordDocumentEquality();

  @override
  bool equals(ExportLogsRecord? e1, ExportLogsRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.timestamp == e2?.timestamp &&
        e1?.status == e2?.status;
  }

  @override
  int hash(ExportLogsRecord? e) =>
      const ListEquality().hash([e?.userId, e?.timestamp, e?.status]);

  @override
  bool isValidKey(Object? o) => o is ExportLogsRecord;
}
