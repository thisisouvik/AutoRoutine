import 'package:autoroutine/features/routines/cubit/routine_suggest_state.dart';
import 'package:autoroutine/features/routines/data/activity_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoutineSuggestCubit extends Cubit<RoutineSuggestState> {
  final ActivityRepository activityRepository;

  RoutineSuggestCubit(this.activityRepository) : super(RoutineSuggestInitial());

  Future<void> loadSuggestions({int days = 30, int minFreq = 2}) async {
    emit(RoutineSuggestLoading());

    try {
      final suggestions = await activityRepository.getSuggestedRoutines(
        days: days,
        minFrequency: minFreq,
      );
      emit(RoutineSuggestLoaded(suggestions));
    } catch (e) {
      emit(RoutineSuggestError(e.toString()));
    }
  }
}
