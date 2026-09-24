import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:app_movil_sistema/features/role/domain/usecases/role_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RoleStatus { initial, loading, success, failure }

class RoleState {
  const RoleState({
    this.status = RoleStatus.initial,
    this.roles = const [],
    this.permissions,
    this.errorMessage,
    this.isSaving = false,
    this.saved = false,
  });

  final RoleStatus status;
  final List<AppRole> roles;
  final RolePermissions? permissions;
  final String? errorMessage;
  final bool isSaving;
  final bool saved;

  RoleState copyWith({
    RoleStatus? status,
    List<AppRole>? roles,
    RolePermissions? permissions,
    bool clearPermissions = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSaving,
    bool? saved,
  }) => RoleState(
    status: status ?? this.status,
    roles: roles ?? this.roles,
    permissions: clearPermissions ? null : permissions ?? this.permissions,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    isSaving: isSaving ?? this.isSaving,
    saved: saved ?? this.saved,
  );
}

class RoleCubit extends Cubit<RoleState> {
  RoleCubit(this._getRoles, this._getPermissions, this._updatePermissions)
    : super(const RoleState());

  final GetRolesUseCase _getRoles;
  final GetRolePermissionsUseCase _getPermissions;
  final UpdateRolePermissionsUseCase _updatePermissions;

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

  void clearFeedback() => emit(state.copyWith(clearError: true, saved: false));
}
