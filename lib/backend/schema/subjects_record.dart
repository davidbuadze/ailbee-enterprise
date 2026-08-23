import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SubjectsRecord extends FirestoreRecord {
  SubjectsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "subject_id" field.
  String? _subjectId;
  String get subjectId => _subjectId ?? '';
  bool hasSubjectId() => _subjectId != null;

  // "name_ka" field.
  String? _nameKa;
  String get nameKa => _nameKa ?? '';
  bool hasNameKa() => _nameKa != null;

  // "name_ru" field.
  String? _nameRu;
  String get nameRu => _nameRu ?? '';
  bool hasNameRu() => _nameRu != null;

  // "name_en" field.
  String? _nameEn;
  String get nameEn => _nameEn ?? '';
  bool hasNameEn() => _nameEn != null;

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

  void _initializeFields() {
    _subjectId = snapshotData['subject_id'] as String?;
    _nameKa = snapshotData['name_ka'] as String?;
    _nameRu = snapshotData['name_ru'] as String?;
    _nameEn = snapshotData['name_en'] as String?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'ailbee')
          .collection('subjects');

  static Stream<SubjectsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SubjectsRecord.fromSnapshot(s));

  static Future<SubjectsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SubjectsRecord.fromSnapshot(s));

  static SubjectsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SubjectsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SubjectsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SubjectsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SubjectsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SubjectsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSubjectsRecordData({
  String? subjectId,
  String? nameKa,
  String? nameRu,
  String? nameEn,
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'subject_id': subjectId,
      'name_ka': nameKa,
      'name_ru': nameRu,
      'name_en': nameEn,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
    }.withoutNulls,
  );

  return firestoreData;
}

class SubjectsRecordDocumentEquality implements Equality<SubjectsRecord> {
  const SubjectsRecordDocumentEquality();

  @override
  bool equals(SubjectsRecord? e1, SubjectsRecord? e2) {
    return e1?.subjectId == e2?.subjectId &&
        e1?.nameKa == e2?.nameKa &&
        e1?.nameRu == e2?.nameRu &&
        e1?.nameEn == e2?.nameEn &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber;
  }

  @override
  int hash(SubjectsRecord? e) => const ListEquality().hash([
        e?.subjectId,
        e?.nameKa,
        e?.nameRu,
        e?.nameEn,
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber
      ]);

  @override
  bool isValidKey(Object? o) => o is SubjectsRecord;
}
