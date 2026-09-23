import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';
import 'package:app_movil_sistema/features/user/domain/usecases/user_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum UserStatus { initial, loading, success, failure }

class UserState {
  const UserState({
    this.status = UserStatus.initial,
    this.users = const [],
    this.filter = const UserFilter(),
    this.form,
    this.error,
    this.saved = false,
    this.saving = false,
  });
  final UserStatus status;
  final List<AppUser> users;
  final UserFilter filter;
  final UserFormData? form;
  final String? error;
  final bool saved;
  final bool saving;
  UserState copyWith({
    UserStatus? status,
    List<AppUser>? users,
    UserFilter? filter,
    UserFormData? form,
    bool clearForm = false,
    String? error,
    bool clearError = false,
    bool? saved,
    bool? saving,
  }) => UserState(
    status: status ?? this.status,
    users: users ?? this.users,
    filter: filter ?? this.filter,
    form: clearForm ? null : form ?? this.form,
    error: clearError ? null : error ?? this.error,
    saved: saved ?? this.saved,
    saving: saving ?? this.saving,
  );
}

class UserCubit extends Cubit<UserState> {
  UserCubit(this._get, this._form, this._create, this._update, this._status)
    : super(const UserState());
  final GetUsersUseCase _get;
  final GetUserFormUseCase _form;
  final CreateUserUseCase _create;
  final UpdateUserUseCase _update;
  final UpdateUserStatusUseCase _status;
  Future<void> load([UserFilter? filter]) async {
    final f = filter ?? state.filter;
    emit(
      state.copyWith(status: UserStatus.loading, filter: f, clearError: true),
    );
    final r = await _get(f);
    r.fold(
      (x) => emit(state.copyWith(status: UserStatus.failure, error: x.message)),
      (x) => emit(state.copyWith(status: UserStatus.success, users: x)),
    );
  }

  Future<void> loadForm([int? id]) async {
    emit(state.copyWith(status: UserStatus.loading, clearError: true));
    final r = await _form(id);
    r.fold(
      (x) => emit(state.copyWith(status: UserStatus.failure, error: x.message)),
      (x) => emit(state.copyWith(status: UserStatus.success, form: x)),
    );
  }

  Future<void> save(UserRequest request) async {
    emit(state.copyWith(saving: true, clearError: true, saved: false));
    final r = request.id == null
        ? await _create(request)
        : await _update(request);
    r.fold(
      (x) => emit(state.copyWith(saving: false, error: x.message)),
      (_) => emit(state.copyWith(saving: false, saved: true)),
    );
  }

  Future<void> toggle(int id) async {
    emit(state.copyWith(saving: true, clearError: true));
    final r = await _status(id);
    r.fold(
      (x) => emit(state.copyWith(saving: false, error: x.message)),
      (_) => emit(state.copyWith(saving: false, saved: true)),
    );
  }

  void clearFeedback() =>
      emit(state.copyWith(clearError: true, saved: false, clearForm: true));
}
