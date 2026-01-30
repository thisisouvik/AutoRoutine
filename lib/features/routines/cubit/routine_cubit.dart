import 'package:autoroutine/features/routines/cubit/routine_state.dart';
import 'package:autoroutine/features/routines/data/routine_repository.dart';
import 'package:autoroutine/core/utils/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoutineCubit extends Cubit<RoutineState> {
  final RoutineRepository repository;

  RoutineCubit(this.repository) : super(RoutineInitial());

  Future<void> loadRoutines() async {
    emit(RoutineLoading());

    try {
      final routines = await repository.fetchRoutine();
      emit(RoutineLoaded(routines.toList()));
      await NotificationService.syncRoutineNotifications(routines.toList());
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }

  Future<void> loadRoutinesByType(String scheduleType) async {
    emit(RoutineLoading());

    try {
      final routines = await repository.fetchRoutinesByType(scheduleType);
      emit(RoutineLoaded(routines.toList()));
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }

  Future<void> addRoutine({
    required int hour,
    required int minute,
    required String message,
    String scheduleType = 'General',
    String scheduleFrequency = 'Every day',
    String? templateName,
    String taskType = 'routine',
  }) async {
    try {
      await repository.addRoutine(
        hour: hour,
        minute: minute,
        message: message,
        scheduleType: scheduleType,
        scheduleFrequency: scheduleFrequency,
        templateName: templateName,
        taskType: taskType,
      );
      await loadRoutines();
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }

  Future<void> toggleRoutineCompletion(
    String routineId,
    bool isCompleted,
  ) async {
    try {
      await repository.toggleRoutineCompletion(routineId, isCompleted);
      if (isCompleted) {
        await NotificationService.cancelAllForRoutine(routineId);
      }
      await loadRoutines();
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      await repository.deleteRoutine(routineId);
      await NotificationService.cancelAllForRoutine(routineId);
      await loadRoutines();
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }
}
