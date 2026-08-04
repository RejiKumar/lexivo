import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';

abstract class SubscriptionRepository {
  Future<Result<SubscriptionStatus>> getMe();

  Future<Result<SubscriptionStatus>> upgrade();
}
