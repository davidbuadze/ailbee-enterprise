import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AilbeeBooksRecord extends FirestoreRecord {
  AilbeeBooksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "author" field.
  String? _author;
  String get author => _author ?? '';
  bool hasAuthor() => _author != null;

  // "subject_id" field.
  String? _subjectId;
  String get subjectId => _subjectId ?? '';
  bool hasSubjectId() => _subjectId != null;

  // "education_level_id" field.
  String? _educationLevelId;
  String get educationLevelId => _educationLevelId ?? '';
  bool hasEducationLevelId() => _educationLevelId != null;

  // "gs_path" field.
  String? _gsPath;
  String get gsPath => _gsPath ?? '';
  bool hasGsPath() => _gsPath != null;

  // "download_url" field.
  String? _downloadUrl;
  String get downloadUrl => _downloadUrl ?? '';
  bool hasDownloadUrl() => _downloadUrl != null;

  // "vertex_engine_id" field.
  String? _vertexEngineId;
  String get vertexEngineId => _vertexEngineId ?? '';
  bool hasVertexEngineId() => _vertexEngineId != null;

  // "cover_image_url" field.
  String? _coverImageUrl;
  String get coverImageUrl => _coverImageUrl ?? '';
  bool hasCoverImageUrl() => _coverImageUrl != null;

  // "academic_stage" field.
  String? _academicStage;
  String get academicStage => _academicStage ?? '';
  bool hasAcademicStage() => _academicStage != null;

  // "category_id" field.
  String? _categoryId;
  String get categoryId => _categoryId ?? '';
  bool hasCategoryId() => _categoryId != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _author = snapshotData['author'] as String?;
    _subjectId = snapshotData['subject_id'] as String?;
    _educationLevelId = snapshotData['education_level_id'] as String?;
    _gsPath = snapshotData['gs_path'] as String?;
    _downloadUrl = snapshotData['download_url'] as String?;
    _vertexEngineId = snapshotData['vertex_engine_id'] as String?;
    _coverImageUrl = snapshotData['cover_image_url'] as String?;
    _academicStage = snapshotData['academic_stage'] as String?;
    _categoryId = snapshotData['category_id'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'ailbee')
          .collection('ailbee-books');

  static Stream<AilbeeBooksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AilbeeBooksRecord.fromSnapshot(s));

  static Future<AilbeeBooksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AilbeeBooksRecord.fromSnapshot(s));

  static AilbeeBooksRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AilbeeBooksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AilbeeBooksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AilbeeBooksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AilbeeBooksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AilbeeBooksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAilbeeBooksRecordData({
  String? title,
  String? author,
  String? subjectId,
  String? educationLevelId,
  String? gsPath,
  String? downloadUrl,
  String? vertexEngineId,
  String? coverImageUrl,
  String? academicStage,
  String? categoryId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'author': author,
      'subject_id': subjectId,
      'education_level_id': educationLevelId,
      'gs_path': gsPath,
      'download_url': downloadUrl,
      'vertex_engine_id': vertexEngineId,
      'cover_image_url': coverImageUrl,
      'academic_stage': academicStage,
      'category_id': categoryId,
    }.withoutNulls,
  );

  return firestoreData;
}

class AilbeeBooksRecordDocumentEquality implements Equality<AilbeeBooksRecord> {
  const AilbeeBooksRecordDocumentEquality();

  @override
  bool equals(AilbeeBooksRecord? e1, AilbeeBooksRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.author == e2?.author &&
        e1?.subjectId == e2?.subjectId &&
        e1?.educationLevelId == e2?.educationLevelId &&
        e1?.gsPath == e2?.gsPath &&
        e1?.downloadUrl == e2?.downloadUrl &&
        e1?.vertexEngineId == e2?.vertexEngineId &&
        e1?.coverImageUrl == e2?.coverImageUrl &&
        e1?.academicStage == e2?.academicStage &&
        e1?.categoryId == e2?.categoryId;
  }

  @override
  int hash(AilbeeBooksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.author,
        e?.subjectId,
        e?.educationLevelId,
        e?.gsPath,
        e?.downloadUrl,
        e?.vertexEngineId,
        e?.coverImageUrl,
        e?.academicStage,
        e?.categoryId
      ]);

  @override
  bool isValidKey(Object? o) => o is AilbeeBooksRecord;
}
