import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getStats, this._checkExpired) : super(DashboardInitial());

  final GetDashboardStatsUseCase _getStats;
  final CheckExpiredAccountsUseCase _checkExpired;

  Future<void> load() async {
    emit(DashboardLoading());
    await _checkExpired(const NoParams());
    final result = await _getStats(const NoParams());
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (stats) => emit(DashboardLoaded(stats)),
    );
  }
}
