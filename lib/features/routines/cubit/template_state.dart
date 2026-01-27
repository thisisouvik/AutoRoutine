import 'package:autoroutine/features/routines/data/template_model.dart';
import 'package:equatable/equatable.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();

  @override
  List<Object?> get props => [];
}

class TemplateInitial extends TemplateState {}

class TemplateLoading extends TemplateState {}

class TemplateLoaded extends TemplateState {
  final List<RoutineTemplate> templates;
  const TemplateLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

class TemplateError extends TemplateState {
  final String message;
  const TemplateError(this.message);

  @override
  List<Object?> get props => [message];
}

class TemplateCreating extends TemplateState {}

class TemplateCreated extends TemplateState {
  final String templateId;
  const TemplateCreated(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

class TemplateApplying extends TemplateState {}

class TemplateApplied extends TemplateState {}
