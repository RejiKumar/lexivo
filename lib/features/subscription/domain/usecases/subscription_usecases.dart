import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/domain/repositories/subscription_repository.dart';

class GetSubscriptionMe {
  const GetSubscriptionMe(this._repo);

  final SubscriptionRepository _repo;

  Future<Result<SubscriptionStatus>> call() => _repo.getMe();
}

class UpgradeSubscription {
  const UpgradeSubscription(this._repo);

  final SubscriptionRepository _repo;

  Future<Result<SubscriptionStatus>> call() => _repo.upgrade();
}
