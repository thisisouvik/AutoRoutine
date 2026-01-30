part of 'add_routine_cubit.dart';

abstract class AddRoutineState {}

class AddRoutineInitial extends AddRoutineState {
  final AddRoutineFormData formData;

  AddRoutineInitial({required this.formData});

  AddRoutineInitial copyWith({AddRoutineFormData? formData}) {
    return AddRoutineInitial(formData: formData ?? this.formData);
  }
}

class AddRoutineError extends AddRoutineState {
  final String message;

  AddRoutineError(this.message);
}

class AddRoutineValid extends AddRoutineState {
  final AddRoutineFormData formData;

  AddRoutineValid(this.formData);
}
