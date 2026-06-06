class SubscriptionUtils {
  SubscriptionUtils._();

  static String computeStatus({
    required DateTime? subscriptionEnd,
    required String accountStatus,
    required bool subscriptionSuspended,
  }) {
    if (subscriptionSuspended || accountStatus == 'suspended') {
      return 'suspended';
    }
    if (subscriptionEnd == null) return 'expired';
    final now = DateTime.now();
    if (subscriptionEnd.isBefore(now)) return 'expired';
    final daysRemaining = subscriptionEnd.difference(now).inDays;
    if (daysRemaining <= 7) return 'expiring_soon';
    return 'active';
  }

  static DateTime addDays(DateTime base, int days) =>
      base.add(Duration(days: days));
}
