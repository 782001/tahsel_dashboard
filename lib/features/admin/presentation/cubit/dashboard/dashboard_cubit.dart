import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/base_usecase/base_usecase.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getStats) : super(DashboardInitial());

  final GetDashboardStatsUseCase _getStats;

  Future<void> load() async {
    emit(DashboardLoading());
    final result = await _getStats(const NoParams());
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (stats) => emit(DashboardLoaded(stats)),
    );
  }
}
