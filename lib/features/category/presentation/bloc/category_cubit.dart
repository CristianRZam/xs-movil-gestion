import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/category_update_request.dart';
import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';
import 'package:app_movil_sistema/features/category/domain/usecases/category_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.search,
    this.errorMessage,
    this.created = false,
    this.updated = false,
    this.isSaving = false,
  });

  final CategoryStatus status;
  final List<ProductCategory> categories;
  final String? search;
  final String? errorMessage;
  final bool created;
  final bool updated;
  final bool isSaving;

  CategoryState copyWith({
    CategoryStatus? status,
    List<ProductCategory>? categories,
    String? search,
    bool clearSearch = false,
    String? errorMessage,
    bool clearError = false,
    bool? created,
    bool? updated,
    bool? isSaving,
  }) => CategoryState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    search: clearSearch ? null : search ?? this.search,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    created: created ?? this.created,
    updated: updated ?? this.updated,
    isSaving: isSaving ?? this.isSaving,
  );
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(
    this._getCategories,
    this._getCategoryForm,
    this._createCategory,
    this._updateCategory,
  ) : super(const CategoryState());

  final GetCategoriesUseCase _getCategories;
  final GetCategoryFormUseCase _getCategoryForm;
  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;

  Future<void> load([String? search]) async {
    final normalizedSearch = search?.trim();
    emit(
      state.copyWith(
        status: CategoryStatus.loading,
        search: normalizedSearch,
        clearSearch: normalizedSearch == null || normalizedSearch.isEmpty,
        clearError: true,
      ),
    );
    final result = await _getCategories(
      search: normalizedSearch?.isEmpty == true ? null : normalizedSearch,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CategoryStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(status: CategoryStatus.success, categories: categories),
      ),
    );
  }

  Future<void> create(CategoryCreateRequest request) async {
    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
        created: false,
        updated: false,
      ),
    );
    final result = await _createCategory(request);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, created: true)),
    );
  }

  Future<ProductCategory?> loadForEdit(int id) async {
    final result = await _getCategoryForm(id);
    return result.fold((failure) {
      emit(state.copyWith(errorMessage: failure.message));
      return null;
    }, (category) => category);
  }

  Future<void> update(CategoryUpdateRequest request) async {
    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
        created: false,
        updated: false,
      ),
    );
    final result = await _updateCategory(request);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, updated: true)),
    );
  }

  void clearFeedback() =>
      emit(state.copyWith(clearError: true, created: false, updated: false));
}
