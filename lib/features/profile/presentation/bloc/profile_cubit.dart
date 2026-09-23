import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';
import 'package:app_movil_sistema/features/profile/domain/usecases/profile_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdatingPassword = false,
    this.error,
    this.passwordUpdated = false,
  });

  final UserProfile? profile;
  final bool isLoading;
  final bool isUpdatingPassword;
  final String? error;
  final bool passwordUpdated;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUpdatingPassword,
    String? error,
    bool? passwordUpdated,
  }) => ProfileState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    isUpdatingPassword: isUpdatingPassword ?? this.isUpdatingPassword,
    error: error,
    passwordUpdated: passwordUpdated ?? this.passwordUpdated,
  );
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile, this._updatePassword)
    : super(const ProfileState());

  final GetProfileUseCase _getProfile;
  final UpdateProfilePasswordUseCase _updatePassword;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getProfile();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
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
        state.copyWith(isUpdatingPassword: false, error: failure.message),
      ),
      (_) => emit(
        state.copyWith(isUpdatingPassword: false, passwordUpdated: true),
      ),
    );
  }

  void clearMessage() =>
      emit(state.copyWith(error: null, passwordUpdated: false));
}
