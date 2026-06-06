import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/broadcast_notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<BroadcastNotification> items;
  const NotificationsLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}
