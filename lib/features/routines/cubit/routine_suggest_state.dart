import 'package:equatable/equatable.dart';

abstract class RoutineSuggestState extends Equatable {
  const RoutineSuggestState();

  @override
  List<Object?> get props => [];
}

class RoutineSuggestInitial extends RoutineSuggestState {}

class RoutineSuggestLoading extends RoutineSuggestState {}

class RoutineSuggestLoaded extends RoutineSuggestState {
  final List<String> suggestions;
  const RoutineSuggestLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

class RoutineSuggestError extends RoutineSuggestState {
  final String message;
  const RoutineSuggestError(this.message);

  @override
  List<Object?> get props => [message];
}
