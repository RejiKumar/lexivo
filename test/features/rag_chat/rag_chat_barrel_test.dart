import 'package:flutter_test/flutter_test.dart';
import 'package:lexivo/features/rag_chat/rag_chat.dart';

void main() {
  test('rag_chat barrel exports core overrides', () {
    expect(ragChatCoreOverrides(), isNotEmpty);
  });
}
