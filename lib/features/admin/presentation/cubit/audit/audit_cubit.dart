import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/audit/audit_state.dart';

class AuditCubit extends Cubit<AuditState> {
  AuditCubit(this._getAuditLogs) : super(AuditInitial());

  final GetAuditLogsUseCase _getAuditLogs;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) emit(AuditLoading());
    final result = await _getAuditLogs(AuditQueryParams());
    result.fold(
      (f) => emit(AuditError(f.message)),
      (page) => emit(AuditLoaded(
        logs: page.items,
        hasMore: page.hasMore,
        cursor: page.lastCursor,
      )),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! AuditLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getAuditLogs(AuditQueryParams(cursor: current.cursor));
    result.fold(
      (f) => emit(AuditError(f.message)),
      (page) => emit(AuditLoaded(
        logs: [...current.logs, ...page.items],
        hasMore: page.hasMore,
        cursor: page.lastCursor,
      )),
    );
  }
}
