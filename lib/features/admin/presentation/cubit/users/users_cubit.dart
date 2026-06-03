import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/users/users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({
    required GetUsersUseCase getUsers,
    required SearchUsersUseCase searchUsers,
    required CreateUserUseCase createUser,
    required DeleteUserUseCase deleteUser,
    required SuspendUserUseCase suspendUser,
    required ActivateUserUseCase activateUser,
  })  : _getUsers = getUsers,
        _searchUsers = searchUsers,
        _createUser = createUser,
        _deleteUser = deleteUser,
        _suspendUser = suspendUser,
        _activateUser = activateUser,
        super(UsersInitial());

  final GetUsersUseCase _getUsers;
  final SearchUsersUseCase _searchUsers;
  final CreateUserUseCase _createUser;
  final DeleteUserUseCase _deleteUser;
  final SuspendUserUseCase _suspendUser;
  final ActivateUserUseCase _activateUser;

  Timer? _debounce;
  String? _accountStatus;
  String? _subscriptionStatus;
  String _searchQuery = '';

  Future<void> load({bool refresh = false}) async {
    if (!refresh) emit(UsersLoading());
    final result = _searchQuery.isNotEmpty
        ? await _searchUsers(SearchParams(query: _searchQuery))
        : await _getUsers(UsersQueryParams(
            accountStatus: _accountStatus,
            subscriptionStatus: _subscriptionStatus,
          ));
    result.fold(
      (f) => emit(UsersError(f.message)),
      (page) => emit(UsersLoaded(
        users: page.items,
        hasMore: page.hasMore,
        cursor: page.lastCursor,
      )),
    );
  }

  void search(String query) {
    _debounce?.cancel();
    _searchQuery = query.trim();
    _debounce = Timer(
      const Duration(milliseconds: AdminConstants.searchDebounceMs),
      () => load(refresh: true),
    );
  }

  void setFilters({String? accountStatus, String? subscriptionStatus}) {
    _accountStatus = accountStatus;
    _subscriptionStatus = subscriptionStatus;
    load(refresh: true);
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! UsersLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = _searchQuery.isNotEmpty
        ? await _searchUsers(SearchParams(
            query: _searchQuery,
            cursor: current.cursor,
          ))
        : await _getUsers(UsersQueryParams(
            cursor: current.cursor,
            accountStatus: _accountStatus,
            subscriptionStatus: _subscriptionStatus,
          ));
    result.fold(
      (f) => emit(UsersError(f.message)),
      (page) => emit(UsersLoaded(
        users: [...current.users, ...page.items],
        hasMore: page.hasMore,
        cursor: page.lastCursor,
      )),
    );
  }

  Future<bool> createUser(CreateUserParams params) async {
    final result = await _createUser(params);
    return result.fold((f) {
      emit(UserActionError(f.message));
      return false;
    }, (_) {
      load(refresh: true);
      return true;
    });
  }

  Future<bool> deleteUser(String uid) async {
    final result = await _deleteUser(uid);
    return result.fold((f) {
      emit(UserActionError(f.message));
      return false;
    }, (_) {
      load(refresh: true);
      return true;
    });
  }

  Future<bool> suspendUser(String uid) async {
    final result = await _suspendUser(uid);
    return result.fold((f) {
      emit(UserActionError(f.message));
      return false;
    }, (_) {
      load(refresh: true);
      return true;
    });
  }

  Future<bool> activateUser(String uid) async {
    final result = await _activateUser(uid);
    return result.fold((f) {
      emit(UserActionError(f.message));
      return false;
    }, (_) {
      load(refresh: true);
      return true;
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

class ExpirationCubit extends Cubit<UsersState> {
  ExpirationCubit(this._getExpiring) : super(UsersInitial());

  final GetExpiringUsersUseCase _getExpiring;
  int _withinDays = 7;

  Future<void> load({int? withinDays, bool refresh = false}) async {
    if (withinDays != null) _withinDays = withinDays;
    if (!refresh) emit(UsersLoading());
    final result = await _getExpiring(ExpiringParams(withinDays: _withinDays));
    result.fold(
      (f) => emit(UsersError(f.message)),
      (page) => emit(UsersLoaded(
        users: page.items,
        hasMore: page.hasMore,
        cursor: page.lastCursor,
      )),
    );
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! UsersLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getExpiring(ExpiringParams(
      withinDays: _withinDays,
      cursor: current.cursor,
    ));
    result.fold(
      (f) => emit(UsersError(f.message)),
      (page) => emit(UsersLoaded(
        users: [...current.users, ...page.items],
        hasMore: page.hasMore,
        cursor: page.lastCursor,
      )),
    );
  }
}
