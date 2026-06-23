import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AilbeeUserDataRecord extends FirestoreRecord {
  AilbeeUserDataRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "plan_type" field.
  String? _planType;
  String get planType => _planType ?? '';
  bool hasPlanType() => _planType != null;

  // "storage_used_bytes" field.
  int? _storageUsedBytes;
  int get storageUsedBytes => _storageUsedBytes ?? 0;
  bool hasStorageUsedBytes() => _storageUsedBytes != null;

  // "subscribed_subjects" field.
  List<String>? _subscribedSubjects;
  List<String> get subscribedSubjects => _subscribedSubjects ?? const [];
  bool hasSubscribedSubjects() => _subscribedSubjects != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "last_activity" field.
  DateTime? _lastActivity;
  DateTime? get lastActivity => _lastActivity;
  bool hasLastActivity() => _lastActivity != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _planType = snapshotData['plan_type'] as String?;
    _storageUsedBytes = castToType<int>(snapshotData['storage_used_bytes']);
    _subscribedSubjects = getDataList(snapshotData['subscribed_subjects']);
    _status = snapshotData['status'] as String?;
    _lastActivity = snapshotData['last_activity'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'ailbee')
          .collection('ailbee-user-data');

  static Stream<AilbeeUserDataRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AilbeeUserDataRecord.fromSnapshot(s));

  static Future<AilbeeUserDataRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AilbeeUserDataRecord.fromSnapshot(s));

  static AilbeeUserDataRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AilbeeUserDataRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AilbeeUserDataRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AilbeeUserDataRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AilbeeUserDataRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AilbeeUserDataRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAilbeeUserDataRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? planType,
  int? storageUsedBytes,
  String? status,
  DateTime? lastActivity,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'plan_type': planType,
      'storage_used_bytes': storageUsedBytes,
      'status': status,
      'last_activity': lastActivity,
    }.withoutNulls,
  );

  return firestoreData;
}

class AilbeeUserDataRecordDocumentEquality
    implements Equality<AilbeeUserDataRecord> {
  const AilbeeUserDataRecordDocumentEquality();

  @override
  bool equals(AilbeeUserDataRecord? e1, AilbeeUserDataRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.planType == e2?.planType &&
        e1?.storageUsedBytes == e2?.storageUsedBytes &&
        listEquality.equals(e1?.subscribedSubjects, e2?.subscribedSubjects) &&
        e1?.status == e2?.status &&
        e1?.lastActivity == e2?.lastActivity;
  }

  @override
  int hash(AilbeeUserDataRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.planType,
        e?.storageUsedBytes,
        e?.subscribedSubjects,
        e?.status,
        e?.lastActivity
      ]);

  @override
  bool isValidKey(Object? o) => o is AilbeeUserDataRecord;
}
