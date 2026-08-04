import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:lexivo/features/ocr/domain/repositories/ocr_repository.dart';

class OcrRepositoryImpl implements OcrRepository {
  OcrRepositoryImpl(this._remote);

  final OcrRemoteDatasource _remote;

  @override
  Future<Result<Document>> getDocument(String id) => _remote.getDocument(id);

  @override
  Future<Result<DocumentStatus>> getStatus(String id) => _remote.getStatus(id);
}
