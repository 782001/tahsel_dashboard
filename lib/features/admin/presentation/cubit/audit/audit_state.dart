import 'package:equatable/equatable.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/audit_log.dart';

abstract class AuditState extends Equatable {
  const AuditState();
  @override
  List<Object?> get props => [];
}

class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<AuditLog> logs;
  final bool hasMore;
  final String? cursor;
  final bool isLoadingMore;

  /// Non-null when a `loadMore` call fails. The existing [logs] are preserved
  /// so the user does not lose their scroll position.
  final String? loadMoreError;

  const AuditLoaded({
    required this.logs,
    required this.hasMore,
    this.cursor,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  AuditLoaded copyWith({
    List<AuditLog>? logs,
    bool? hasMore,
    String? cursor,
    bool? isLoadingMore,
    // Pass null explicitly to clear the error after it has been consumed.
    Object? loadMoreError = _sentinel,
  }) =>
      AuditLoaded(
        logs: logs ?? this.logs,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreError:
            loadMoreError == _sentinel ? this.loadMoreError : loadMoreError as String?,
      );

  @override
  List<Object?> get props => [logs, hasMore, cursor, isLoadingMore, loadMoreError];
}

// Sentinel used so `copyWith` can distinguish "not passed" from explicit null.
const Object _sentinel = Object();

class AuditError extends AuditState {
  final String message;
  const AuditError(this.message);
  @override
  List<Object?> get props => [message];
}
