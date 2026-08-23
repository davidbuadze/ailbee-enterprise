import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TasksRecord extends FirestoreRecord {
  TasksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "due_date" field.
  DateTime? _dueDate;
  DateTime? get dueDate => _dueDate;
  bool hasDueDate() => _dueDate != null;

  // "is_completed" field.
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "calendar_event_id" field.
  String? _calendarEventId;
  String get calendarEventId => _calendarEventId ?? '';
  bool hasCalendarEventId() => _calendarEventId != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _dueDate = snapshotData['due_date'] as DateTime?;
    _isCompleted = snapshotData['is_completed'] as bool?;
    _calendarEventId = snapshotData['calendar_event_id'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'ailbee')
          .collection('tasks');

  static Stream<TasksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TasksRecord.fromSnapshot(s));

  static Future<TasksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TasksRecord.fromSnapshot(s));

  static TasksRecord fromSnapshot(DocumentSnapshot snapshot) => TasksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TasksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TasksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TasksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TasksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTasksRecordData({
  String? title,
  DateTime? dueDate,
  bool? isCompleted,
  String? calendarEventId,
  DateTime? createdAt,
  DocumentReference? userRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'due_date': dueDate,
      'is_completed': isCompleted,
      'calendar_event_id': calendarEventId,
      'created_at': createdAt,
      'user_ref': userRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class TasksRecordDocumentEquality implements Equality<TasksRecord> {
  const TasksRecordDocumentEquality();

  @override
  bool equals(TasksRecord? e1, TasksRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.dueDate == e2?.dueDate &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.calendarEventId == e2?.calendarEventId &&
        e1?.createdAt == e2?.createdAt &&
        e1?.userRef == e2?.userRef;
  }

  @override
  int hash(TasksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.dueDate,
        e?.isCompleted,
        e?.calendarEventId,
        e?.createdAt,
        e?.userRef
      ]);

  @override
  bool isValidKey(Object? o) => o is TasksRecord;
}
