import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lexivo/core/network/api_client.dart';
import 'package:lexivo/core/utils/result.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_harness.dart';

void main() {
  late ApiClient client;
  late DioAdapter adapter;

  setUp(() {
    final dio = createTestDio();
    adapter = DioAdapter(dio: dio);
    client = ApiClient(dio);
  });

  group('ApiClient notifications', () {
    test('listNotifications parses mixed read/unread', () async {
      adapter.onGet(
        '/api/v1/notifications',
        (server) => server.reply(
          200,
          readFixtureSync('notifications/notifications_mixed.json'),
        ),
      );

      final result = await client.listNotifications();
      expect(result.isSuccess, isTrue);
      final list = result.valueOrNull!;
      expect(list.total, 3);
      expect(list.items.length, 3);
      expect(list.items.first.id, 'notif-1');
      expect(list.items.first.title, 'OCR complete');
      expect(list.items.first.readAt, isNull);
      expect(list.items[1].readAt, isNotNull);
      expect(list.items.first.payload['document_id'], 'doc-1');
      expect(list.items.first.createdAt, isNotNull);
    });

    test('listNotifications empty is valid', () async {
      adapter.onGet(
        '/api/v1/notifications',
        (server) => server.reply(
          200,
          readFixtureSync('notifications/notifications_empty.json'),
        ),
      );
      final result = await client.listNotifications();
      expect(result.valueOrNull?.items, isEmpty);
      expect(result.valueOrNull?.total, 0);
    });

    test('markNotificationRead parses response', () async {
      adapter.onPost(
        '/api/v1/notifications/notif-1/read',
        (server) => server.reply(
          200,
          readFixtureSync('notifications/notification_mark_read.json'),
        ),
      );
      final result = await client.markNotificationRead('notif-1');
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.readAt, isNotNull);
      expect(result.valueOrNull?.title, 'OCR complete');
    });

    test('markNotificationRead 404 → NetworkFailure', () async {
      adapter.onPost(
        '/api/v1/notifications/missing/read',
        (server) => server.reply(
          404,
          readFixtureSync('notifications/notification_404.json'),
        ),
      );
      final result = await client.markNotificationRead('missing');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.failureOrNull?.message.toLowerCase(), contains('not found'));
    });

    test('listNotifications 401 → UnauthorizedFailure', () async {
      adapter.onGet(
        '/api/v1/notifications',
        (server) => server.reply(401, {'detail': 'Unauthorized'}),
      );
      final result = await client.listNotifications();
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });
  });
}
