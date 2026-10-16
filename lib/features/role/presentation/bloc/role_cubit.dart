import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:app_movil_sistema/features/role/domain/usecases/role_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RoleStatus { initial, loading, success, failure }

enum RoleSuccess { created, updated, activated, deactivated }

class RoleState {
  const RoleState({
    this.status = RoleStatus.initial,
    this.roles = const [],
    this.permissions,
    this.errorMessage,
    this.isSaving = false,
    this.saved = false,
    this.success,
  });

  final RoleStatus status;
  final List<AppRole> roles;
  final RolePermissions? permissions;
  final String? errorMessage;
  final bool isSaving;
  final bool saved;
  final RoleSuccess? success;

  RoleState copyWith({
    RoleStatus? status,
    List<AppRole>? roles,
    RolePermissions? permissions,
    bool clearPermissions = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSaving,
    bool? saved,
    RoleSuccess? success,
    bool clearSuccess = false,
  }) => RoleState(
    status: status ?? this.status,
    roles: roles ?? this.roles,
    permissions: clearPermissions ? null : permissions ?? this.permissions,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    isSaving: isSaving ?? this.isSaving,
    saved: saved ?? this.saved,
    success: clearSuccess ? null : success ?? this.success,
  );
}

class RoleCubit extends Cubit<RoleState> {
  RoleCubit(
    this._getRoles,
    this._getPermissions,
    this._updatePermissions,
    this._createRole,
    this._updateRole,
    this._updateStatus,
  ) : super(const RoleState());

  final GetRolesUseCase _getRoles;
  final GetRolePermissionsUseCase _getPermissions;
  final UpdateRolePermissionsUseCase _updatePermissions;
  final CreateRoleUseCase _createRole;
  final UpdateRoleUseCase _updateRole;
  final UpdateRoleStatusUseCase _updateStatus;

  Future<void> loadRoles() async {
    emit(state.copyWith(status: RoleStatus.loading, clearError: true));
    final result = await _getRoles();
    result.fold(
      (failure) => emit(state.copyWith(status: RoleStatus.failure, errorMessage: failure.message)),
      (roles) => emit(state.copyWith(status: RoleStatus.success, roles: roles)),
    );
  }

  Future<void> loadPermissions(int roleId) async {
    emit(state.copyWith(status: RoleStatus.loading, clearError: true, clearPermissions: true));
    final result = await _getPermissions(roleId);
    result.fold(
      (failure) => emit(state.copyWith(status: RoleStatus.failure, errorMessage: failure.message)),
      (permissions) => emit(state.copyWith(status: RoleStatus.success, permissions: permissions)),
    );
  }

  Future<void> savePermissions(int roleId, Set<int> permissionIds) async {
    emit(state.copyWith(isSaving: true, saved: false, clearError: true));
    final result = await _updatePermissions(roleId: roleId, permissionIds: permissionIds);
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, saved: true)),
    );
  }

  Future<void> save(RoleRequest request) async {
    emit(
      state.copyWith(
        isSaving: true,
        saved: false,
        clearError: true,
        clearSuccess: true,
      ),
    );
    final result = request.id == null
        ? await _createRole(request)
        : await _updateRole(request);
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          saved: true,
          success: request.id == null ? RoleSuccess.created : RoleSuccess.updated,
        ),
      ),
    );
  }

  Future<void> toggle(AppRole role) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    final result = await _updateStatus(role.id);
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(
        state.copyWith(
          isSaving: false,
          saved: true,
          success: role.active ? RoleSuccess.deactivated : RoleSuccess.activated,
        ),
      ),
    );
  }

  void clearFeedback() => emit(
    state.copyWith(clearError: true, saved: false, clearSuccess: true),
  );
}
