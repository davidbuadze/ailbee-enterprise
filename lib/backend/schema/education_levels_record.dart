import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EducationLevelsRecord extends FirestoreRecord {
  EducationLevelsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "level_id" field.
  String? _levelId;
  String get levelId => _levelId ?? '';
  bool hasLevelId() => _levelId != null;

  // "name_ru" field.
  String? _nameRu;
  String get nameRu => _nameRu ?? '';
  bool hasNameRu() => _nameRu != null;

  // "name_ka" field.
  String? _nameKa;
  String get nameKa => _nameKa ?? '';
  bool hasNameKa() => _nameKa != null;

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
    _levelId = snapshotData['level_id'] as String?;
    _nameRu = snapshotData['name_ru'] as String?;
    _nameKa = snapshotData['name_ka'] as String?;
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
          .collection('education_levels');

  static Stream<EducationLevelsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EducationLevelsRecord.fromSnapshot(s));

  static Future<EducationLevelsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => EducationLevelsRecord.fromSnapshot(s));

  static EducationLevelsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      EducationLevelsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EducationLevelsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EducationLevelsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EducationLevelsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EducationLevelsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEducationLevelsRecordData({
  String? levelId,
  String? nameRu,
  String? nameKa,
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
      'level_id': levelId,
      'name_ru': nameRu,
      'name_ka': nameKa,
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

class EducationLevelsRecordDocumentEquality
    implements Equality<EducationLevelsRecord> {
  const EducationLevelsRecordDocumentEquality();

  @override
  bool equals(EducationLevelsRecord? e1, EducationLevelsRecord? e2) {
    return e1?.levelId == e2?.levelId &&
        e1?.nameRu == e2?.nameRu &&
        e1?.nameKa == e2?.nameKa &&
        e1?.nameEn == e2?.nameEn &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber;
  }

  @override
  int hash(EducationLevelsRecord? e) => const ListEquality().hash([
        e?.levelId,
        e?.nameRu,
        e?.nameKa,
        e?.nameEn,
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber
      ]);

  @override
  bool isValidKey(Object? o) => o is EducationLevelsRecord;
}
