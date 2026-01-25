import 'package:autoroutine/features/routines/cubit/routine_state.dart';
import 'package:autoroutine/features/routines/data/routine_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoutineCubit extends Cubit<RoutineState> {
  final RoutineRepository repository;

  RoutineCubit(this.repository) : super(RoutineInitial());

  Future<void> loadRoutines() async {
    emit(RoutineLoading());

    try {
      final routines = await repository.fetchRoutine();
      emit(RoutineLoaded(routines.toList()));
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }

  Future<void> addRoutine({
    required int hour,
    required int minute,
    required String message,
  }) async {
    try {
      await repository.addRoutine(hour: hour, minute: minute, message: message);
      await loadRoutines();
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }
}
