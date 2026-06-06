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

  const AuditLoaded({
    required this.logs,
    required this.hasMore,
    this.cursor,
    this.isLoadingMore = false,
  });

  AuditLoaded copyWith({
    List<AuditLog>? logs,
    bool? hasMore,
    String? cursor,
    bool? isLoadingMore,
  }) =>
      AuditLoaded(
        logs: logs ?? this.logs,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [logs, hasMore, cursor, isLoadingMore];
}

class AuditError extends AuditState {
  final String message;
  const AuditError(this.message);
  @override
  List<Object?> get props => [message];
}
