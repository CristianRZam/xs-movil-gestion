import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';
import 'package:app_movil_sistema/features/profile/domain/usecases/profile_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdatingPassword = false,
    this.isLoadingPermissions = false,
    this.permissions = const [],
    this.error,
    this.errorCode,
    this.passwordUpdated = false,
  });

  final UserProfile? profile;
  final bool isLoading;
  final bool isUpdatingPassword;
  final bool isLoadingPermissions;
  final List<ProfilePermission> permissions;
  final String? error;
  final int? errorCode;
  final bool passwordUpdated;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUpdatingPassword,
    bool? isLoadingPermissions,
    List<ProfilePermission>? permissions,
    String? error,
    int? errorCode,
    bool? passwordUpdated,
  }) => ProfileState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    isUpdatingPassword: isUpdatingPassword ?? this.isUpdatingPassword,
    isLoadingPermissions: isLoadingPermissions ?? this.isLoadingPermissions,
    permissions: permissions ?? this.permissions,
    error: error,
    errorCode: errorCode,
    passwordUpdated: passwordUpdated ?? this.passwordUpdated,
  );
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile, this._updatePassword, this._getMyPermissions)
    : super(const ProfileState());

  final GetProfileUseCase _getProfile;
  final UpdateProfilePasswordUseCase _updatePassword;
  final GetMyPermissionsUseCase _getMyPermissions;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getProfile();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure.message,
          errorCode: failure.code,
        ),
      ),
      (profile) => emit(state.copyWith(isLoading: false, profile: profile)),
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmationPassword,
  }) async {
    emit(
      state.copyWith(
        isUpdatingPassword: true,
        error: null,
        passwordUpdated: false,
      ),
    );
    final result = await _updatePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmationPassword: confirmationPassword,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isUpdatingPassword: false,
          error: failure.message,
          errorCode: failure.code,
        ),
      ),
      (_) => emit(
        state.copyWith(isUpdatingPassword: false, passwordUpdated: true),
      ),
    );
  }

  Future<bool> loadMyPermissions() async {
    emit(state.copyWith(isLoadingPermissions: true, error: null));
    final result = await _getMyPermissions();
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoadingPermissions: false,
            error: failure.message,
            errorCode: failure.code,
          ),
        );
        return false;
      },
      (permissions) {
        emit(
          state.copyWith(
            isLoadingPermissions: false,
            permissions: permissions,
          ),
        );
        return true;
      },
    );
  }

  void clearMessage() =>
      emit(state.copyWith(error: null, errorCode: null, passwordUpdated: false));
}
