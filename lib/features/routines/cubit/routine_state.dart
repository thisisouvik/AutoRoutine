import 'package:autoroutine/features/routines/data/routine_model.dart';
import 'package:equatable/equatable.dart';

abstract class RoutineState extends Equatable {
  const RoutineState();

  @override
  List<Object?> get props => [];
}

class RoutineInitial extends RoutineState {}

class RoutineLoading extends RoutineState {}

class RoutineLoaded extends RoutineState {
  final List<Routine> routines;
  const RoutineLoaded(this.routines);

  @override
  List<Object?> get props => [routines];
}

class RoutineError extends RoutineState {
  final String message;
  const RoutineError(this.message);

  @override
  List<Object?> get props => [message];
}
