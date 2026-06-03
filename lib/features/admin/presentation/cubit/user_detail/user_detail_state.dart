import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_note.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/user_session.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();
  @override
  List<Object?> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailLoaded extends UserDetailState {
  final AppUser user;
  final List<UserNote> notes;
  final List<UserSession> sessions;
  final bool notesHasMore;
  final String? notesCursor;

  const UserDetailLoaded({
    required this.user,
    this.notes = const [],
    this.sessions = const [],
    this.notesHasMore = false,
    this.notesCursor,
  });

  UserDetailLoaded copyWith({
    AppUser? user,
    List<UserNote>? notes,
    List<UserSession>? sessions,
    bool? notesHasMore,
    String? notesCursor,
  }) =>
      UserDetailLoaded(
        user: user ?? this.user,
        notes: notes ?? this.notes,
        sessions: sessions ?? this.sessions,
        notesHasMore: notesHasMore ?? this.notesHasMore,
        notesCursor: notesCursor ?? this.notesCursor,
      );

  @override
  List<Object?> get props => [user, notes, sessions, notesHasMore, notesCursor];
}

class UserDetailError extends UserDetailState {
  final String message;
  const UserDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserDetailActionLoading extends UserDetailState {}
