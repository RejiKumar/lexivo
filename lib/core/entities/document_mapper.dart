import 'package:lexivo/core/entities/document.dart';
import 'package:lexivo/core/network/api_models.dart';

/// Maps network DTOs → shared [Document] entity.
Document documentFromDto(DocumentDto dto) {
  return Document(
    id: dto.id,
    userId: dto.userId,
    title: dto.title,
    storageKey: dto.storageKey,
    status: DocumentStatusApiX.fromApi(dto.status),
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );
}

DocumentStatus documentStatusFromDto(DocumentStatusDto dto) {
  return DocumentStatusApiX.fromApi(dto.status);
}
