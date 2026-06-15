import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/services/user_access_policy.dart';

class UserStats extends Equatable {
  final int customers;
  final int debts;
  final int employees;
  final int transactions;
  final int expenses;

  const UserStats({
    this.customers = 0,
    this.debts = 0,
    this.employees = 0,
    this.transactions = 0,
    this.expenses = 0,
  });

  @override
  List<Object?> get props =>
      [customers, debts, employees, transactions, expenses];
}

class AppUser extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String accountStatus;
  final String subscriptionStatus;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final DateTime? lastActive;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final String? devicePlatform;
  final UserStats stats;
  final bool subscriptionSuspended;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.accountStatus,
    required this.subscriptionStatus,
    this.createdAt,
    this.lastLogin,
    this.lastActive,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.devicePlatform,
    this.stats = const UserStats(),
    this.subscriptionSuspended = false,
  });

  int get daysRemaining {
    if (subscriptionEnd == null) return 0;
    final diff = subscriptionEnd!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isActive => accountStatus == 'active';
  bool get isSuspended => accountStatus == 'suspended';
  bool get isDisabled => accountStatus == 'disabled';
  bool get isDeleted => accountStatus == 'deleted';
  DateTime? get gracePeriodEnd =>
      UserAccessPolicy.gracePeriodEnd(subscriptionEnd);
  bool get isLoginAllowed => UserAccessPolicy.isLoginAllowed(
        accountStatus: accountStatus,
        subscriptionSuspended: subscriptionSuspended,
        subscriptionEnd: subscriptionEnd,
      );

  @override
  List<Object?> get props => [
        uid,
        fullName,
        email,
        phoneNumber,
        accountStatus,
        subscriptionStatus,
        createdAt,
        lastLogin,
        lastActive,
        subscriptionStart,
        subscriptionEnd,
        devicePlatform,
        stats,
        subscriptionSuspended,
      ];
}
