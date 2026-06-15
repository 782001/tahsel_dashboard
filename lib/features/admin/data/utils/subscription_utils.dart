import 'package:tahsel_dashboard/features/admin/domain/services/user_access_policy.dart';

class SubscriptionUtils {
  SubscriptionUtils._();

  static const int gracePeriodDays = UserAccessPolicy.gracePeriodDays;

  static String computeStatus({
    required DateTime? subscriptionEnd,
    required String accountStatus,
    required bool subscriptionSuspended,
  }) {
    return UserAccessPolicy.computeSubscriptionStatus(
      subscriptionEnd: subscriptionEnd,
      accountStatus: accountStatus,
      subscriptionSuspended: subscriptionSuspended,
    );
  }

  static DateTime? gracePeriodEnd(DateTime? subscriptionEnd) =>
      UserAccessPolicy.gracePeriodEnd(subscriptionEnd);

  static DateTime addDays(DateTime base, int days) =>
      base.add(Duration(days: days));
}
