import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/rag_chat/data/datasources/rag_chat_remote_datasource.dart';
import 'package:lexivo/features/rag_chat/domain/entities/chat_message.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_harness.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late RagChatRemoteDatasource datasource;

  setUp(() {
    dio = createTestDio(baseUrl: 'http://api.test');
    adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    datasource = RagChatRemoteDatasource(ApiClient(dio));
  });

  test('ensureChat maps ChatDto', () async {
    adapter.onPost(
      '/api/v1/chats/doc-1',
      (server) => server.reply(200, readFixtureSync('chats/chat_created.json')),
    );
    final result = await datasource.ensureChat('doc-1');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.id, 'chat-1');
    expect(result.valueOrNull?.documentId, 'doc-1');
  });

  test('listMessages maps citations', () async {
    adapter.onGet(
      '/api/v1/chats/doc-1/messages',
      (server) =>
          server.reply(200, readFixtureSync('chats/messages_with_citations.json')),
    );
    final result = await datasource.listMessages('doc-1');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.length, 2);
    final assistant = result.valueOrNull!.last;
    expect(assistant.role, ChatMessageRole.assistant);
    expect(assistant.citations.first.label, '§1');
  });

  test('sendMessage maps assistant', () async {
    adapter.onPost(
      '/api/v1/chats/doc-1/messages',
      (server) =>
          server.reply(200, readFixtureSync('chats/message_assistant_cited.json')),
      data: Matchers.any,
    );
    final result = await datasource.sendMessage('doc-1', 'When is rent due?');
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.citations, isNotEmpty);
  });

  test('sendMessage 409 → ValidationFailure', () async {
    adapter.onPost(
      '/api/v1/chats/doc-1/messages',
      (server) =>
          server.reply(409, readFixtureSync('chats/chat_not_ready_409.json')),
      data: Matchers.any,
    );
    final result = await datasource.sendMessage('doc-1', 'Q?');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(result.failureOrNull?.message, contains('not ready'));
  });

  test('sendMessage 422 → ValidationFailure', () async {
    adapter.onPost(
      '/api/v1/chats/doc-1/messages',
      (server) =>
          server.reply(422, readFixtureSync('chats/chat_empty_content_422.json')),
      data: Matchers.any,
    );
    final result = await datasource.sendMessage('doc-1', ' ');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });
}
