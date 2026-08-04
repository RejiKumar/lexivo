import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/core/entities/document.dart';

void main() {
  test('rag_chat readiness uses core Document.status + id/title only', () {
    const doc = Document(
      id: 'doc-1',
      userId: 'u1',
      title: 'Lease',
      status: DocumentStatus.ready,
    );
    expect(doc.id, 'doc-1');
    expect(doc.title, 'Lease');
    expect(doc.status, DocumentStatus.ready);
    // Chat entities are feature-owned — Document has no chat pointer fields.
    expect(doc.toString(), isNot(contains('chatId')));
  });
}
