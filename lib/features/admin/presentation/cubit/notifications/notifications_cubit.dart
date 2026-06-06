import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/models/paginated_result.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/notifications/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required GetNotificationsUseCase getNotifications,
    required SendNotificationUseCase sendNotification,
  })  : _getNotifications = getNotifications,
        _sendNotification = sendNotification,
        super(NotificationsInitial());

  final GetNotificationsUseCase _getNotifications;
  final SendNotificationUseCase _sendNotification;

  Future<void> load() async {
    emit(NotificationsLoading());
    final result = await _getNotifications(const PaginationParams());
    result.fold(
      (f) => emit(NotificationsError(f.message)),
      (page) => emit(NotificationsLoaded(page.items)),
    );
  }

  Future<bool> send({
    required String title,
    required String body,
    required String targetType,
    List<String>? targetIds,
  }) async {
    final result = await _sendNotification(
      NotificationParams(
        title: title,
        body: body,
        targetType: targetType,
        targetIds: targetIds,
      ),
    );
    return result.fold((f) {
      emit(NotificationsError(f.message));
      return false;
    }, (_) {
      load();
      return true;
    });
  }
}
