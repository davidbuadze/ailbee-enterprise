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

  void _initializeFields() {
    _levelId = snapshotData['level_id'] as String?;
    _nameRu = snapshotData['name_ru'] as String?;
    _nameKa = snapshotData['name_ka'] as String?;
    _nameEn = snapshotData['name_en'] as String?;
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
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'level_id': levelId,
      'name_ru': nameRu,
      'name_ka': nameKa,
      'name_en': nameEn,
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
        e1?.nameEn == e2?.nameEn;
  }

  @override
  int hash(EducationLevelsRecord? e) =>
      const ListEquality().hash([e?.levelId, e?.nameRu, e?.nameKa, e?.nameEn]);

  @override
  bool isValidKey(Object? o) => o is EducationLevelsRecord;
}
