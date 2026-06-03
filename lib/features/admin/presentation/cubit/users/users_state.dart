import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';

abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<AppUser> users;
  final bool hasMore;
  final String? cursor;
  final bool isLoadingMore;

  const UsersLoaded({
    required this.users,
    required this.hasMore,
    this.cursor,
    this.isLoadingMore = false,
  });

  UsersLoaded copyWith({
    List<AppUser>? users,
    bool? hasMore,
    String? cursor,
    bool? isLoadingMore,
  }) =>
      UsersLoaded(
        users: users ?? this.users,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [users, hasMore, cursor, isLoadingMore];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserActionSuccess extends UsersState {}

class UserActionError extends UsersState {
  final String message;
  const UserActionError(this.message);
  @override
  List<Object?> get props => [message];
}
