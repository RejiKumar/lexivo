import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';

@freezed
abstract class UsageBucket with _$UsageBucket {
  const factory UsageBucket({
    required int used,
    required int limit,
    required String period,
  }) = _UsageBucket;
}

@freezed
abstract class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required String tier,
    @Default('active') String status,
    required bool paywallEnabled,
    required UsageBucket documents,
    required UsageBucket chatMessages,
    required UsageBucket ocrPages,
  }) = _SubscriptionStatus;

  const SubscriptionStatus._();

  bool get isPaid => tier == 'paid';
  bool get isFree => !isPaid;
}
