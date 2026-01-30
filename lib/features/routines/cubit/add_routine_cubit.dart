import 'package:autoroutine/features/routines/domain/add_routine_model.dart';
import 'package:autoroutine/features/routines/domain/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_routine_state.dart';

class AddRoutineCubit extends Cubit<AddRoutineState> {
  AddRoutineCubit()
    : super(
        AddRoutineInitial(
          formData: AddRoutineFormData(
            taskName: '',
            scheduleFrequency: ScheduleFrequency.daily,
            selectedTime: RoutineTimeOfDay.now(),
            taskType: TaskType.routine,
          ),
        ),
      );

  /// Update task name
  void updateTaskName(String name) {
    final currentState = state as AddRoutineInitial;
    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(taskName: name),
      ),
    );
  }

  /// Update schedule frequency
  void updateScheduleFrequency(ScheduleFrequency frequency) {
    final currentState = state as AddRoutineInitial;
    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(
          scheduleFrequency: frequency,
          selectedDays: frequency == ScheduleFrequency.daily
              ? {}
              : currentState.formData.selectedDays,
        ),
      ),
    );
  }

  /// Toggle day selection
  void toggleDay(DayOfWeek day) {
    final currentState = state as AddRoutineInitial;
    final days = Set<DayOfWeek>.from(currentState.formData.selectedDays);

    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }

    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(selectedDays: days),
      ),
    );
  }

  /// Update selected time
  void updateTime(RoutineTimeOfDay time) {
    final currentState = state as AddRoutineInitial;
    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(selectedTime: time),
      ),
    );
  }

  /// Update custom frequency (days per week)
  void updateCustomFrequency(int daysPerWeek) {
    final currentState = state as AddRoutineInitial;
    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(
          customFrequencyDaysPerWeek: daysPerWeek,
        ),
      ),
    );
  }

  /// Update task type
  void updateTaskType(TaskType type) {
    final currentState = state as AddRoutineInitial;
    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(taskType: type),
      ),
    );
  }

  /// Update selected template
  void updateTemplate(RoutineTemplate template) {
    final currentState = state as AddRoutineInitial;
    emit(
      currentState.copyWith(
        formData: currentState.formData.copyWith(selectedTemplate: template),
      ),
    );
  }

  /// Validate and proceed
  void validateAndProceed() {
    final currentState = state as AddRoutineInitial;
    final validation = currentState.formData.validate();

    if (!validation.isValid) {
      emit(AddRoutineError(validation.error ?? 'Invalid data'));
    } else {
      emit(AddRoutineValid(currentState.formData));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(
      AddRoutineInitial(
        formData: AddRoutineFormData(
          taskName: '',
          scheduleFrequency: ScheduleFrequency.daily,
          selectedTime: RoutineTimeOfDay.now(),
          taskType: TaskType.routine,
        ),
      ),
    );
  }
}
