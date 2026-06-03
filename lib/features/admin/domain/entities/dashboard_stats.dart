import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;
  final int expiredSubscriptions;
  final int expiringSoon;
  final int newUsersThisMonth;
  final double monthlyRevenue;

  const DashboardStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.suspendedUsers = 0,
    this.expiredSubscriptions = 0,
    this.expiringSoon = 0,
    this.newUsersThisMonth = 0,
    this.monthlyRevenue = 0,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        activeUsers,
        suspendedUsers,
        expiredSubscriptions,
        expiringSoon,
        newUsersThisMonth,
        monthlyRevenue,
      ];
}
