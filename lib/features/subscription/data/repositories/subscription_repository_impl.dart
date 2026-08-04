import 'package:lexivo/core/utils/result.dart';
import 'package:lexivo/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:lexivo/features/subscription/domain/entities/subscription_status.dart';
import 'package:lexivo/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._remote);

  final SubscriptionRemoteDatasource _remote;

  SubscriptionStatus? _cached;

  @override
  Future<Result<SubscriptionStatus>> getMe() async {
    final result = await _remote.getMe();
    result.when(
      success: (value) => _cached = value,
      onFailure: (_) {},
    );
    return result;
  }

  @override
  Future<Result<SubscriptionStatus>> upgrade() async {
    final result = await _remote.upgrade(previous: _cached);
    if (result.isSuccess) {
      // Refresh full usage after stub upgrade.
      return getMe();
    }
    return result;
  }
}
