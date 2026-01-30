import 'package:autoroutine/features/routines/cubit/template_state.dart';
import 'package:autoroutine/features/routines/data/celebrity_routines.dart';
import 'package:autoroutine/features/routines/data/template_model.dart';
import 'package:autoroutine/features/routines/data/template_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TemplateCubit extends Cubit<TemplateState> {
  final TemplateRepository repository;

  TemplateCubit(this.repository) : super(TemplateInitial());

  Future<void> loadTemplates() async {
    emit(TemplateLoading());

    try {
      final userTemplates = await repository.fetchTemplates();
      final celebrityTemplates = CelebrityRoutines.getPredefinedTemplates();

      // Combine both lists - celebrities first, then user templates
      final allTemplates = [...celebrityTemplates, ...userTemplates];

      emit(TemplateLoaded(allTemplates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> loadTemplatesByType(String scheduleType) async {
    emit(TemplateLoading());

    try {
      final templates = await repository.fetchTemplatesByType(scheduleType);
      emit(TemplateLoaded(templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> createTemplate({
    required String name,
    String? description,
    String scheduleType = 'General',
    required List<TemplateRoutine> routines,
  }) async {
    emit(TemplateCreating());

    try {
      final templateId = await repository.createTemplate(
        name: name,
        description: description,
        scheduleType: scheduleType,
        routines: routines,
      );
      emit(TemplateCreated(templateId));
      // Reload templates to reflect change
      await loadTemplates();
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      await repository.deleteTemplate(templateId);
      await loadTemplates();
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> toggleTemplateActivation(
    String templateId,
    bool isActive,
  ) async {
    try {
      await repository.toggleTemplateActivation(templateId, isActive);
      await loadTemplates();
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> applyTemplate(
    String templateId, {
    String scheduleType = 'General',
  }) async {
    emit(TemplateApplying());

    try {
      await repository.applyTemplate(templateId, scheduleType: scheduleType);
      emit(TemplateApplied());
      // Brief delay then reload
      await Future.delayed(const Duration(milliseconds: 500));
      await loadTemplates();
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }
}
