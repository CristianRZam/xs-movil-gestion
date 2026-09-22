import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_movil_sistema/features/inventory_count/domain/usecases/inventory_count_usecases.dart';
import 'inventory_count_event.dart';
import 'inventory_count_state.dart';

class InventoryCountBloc
    extends Bloc<InventoryCountEvent, InventoryCountState> {
  final GetCurrentInventoryCountUseCase current;
  final OpenInventoryCountUseCase open;
  final GetInventoryCountDetailUseCase detail;
  final CloseInventoryCountUseCase closeCount;
  InventoryCountBloc(this.current, this.open, this.detail, this.closeCount)
    : super(const InventoryCountState()) {
    on<LoadInventoryCount>(_load);
    on<StartInventoryCount>(_start);
    on<FinishInventoryCount>(_finish);
  }
  Future<void> _load(
    LoadInventoryCount e,
    Emitter<InventoryCountState> emit,
  ) async {
    emit(state.copyWith(status: InventoryCountStatus.loading));
    final r = await current();
    await r.fold(
      (f) async => emit(
        state.copyWith(status: InventoryCountStatus.failure, error: f.message),
      ),
      (s) async {
        if (s == null) {
          emit(const InventoryCountState(status: InventoryCountStatus.success));
          return;
        }
        final d = await detail(s.id);
        d.fold(
          (f) => emit(
            state.copyWith(
              status: InventoryCountStatus.failure,
              error: f.message,
            ),
          ),
          (x) => emit(
            InventoryCountState(
              status: InventoryCountStatus.success,
              session: s,
              items: x,
            ),
          ),
        );
      },
    );
  }

  Future<void> _start(
    StartInventoryCount e,
    Emitter<InventoryCountState> emit,
  ) async {
    final r = await open();
    r.fold(
      (f) => emit(
        state.copyWith(status: InventoryCountStatus.failure, error: f.message),
      ),
      (s) => add(const LoadInventoryCount()),
    );
  }

  Future<void> _finish(
    FinishInventoryCount e,
    Emitter<InventoryCountState> emit,
  ) {
    return closeCount(state.session!.id, e.items).then(
      (r) => r.fold(
        (f) => emit(
          state.copyWith(
            status: InventoryCountStatus.failure,
            error: f.message,
          ),
        ),
        (_) => add(const LoadInventoryCount()),
      ),
    );
  }
}
