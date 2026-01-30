import 'package:autoroutine/features/routines/data/template_model.dart';

/// Predefined celebrity routines that are available to all users
class CelebrityRoutines {
  static List<RoutineTemplate> getPredefinedTemplates() {
    return [
      // Virat Kohli's Routine
      RoutineTemplate(
        id: 'celebrity_virat_kohli',
        userId: 'system',
        name: 'Virat Kohli',
        category: 'Celebrity Routine',
        description: 'Indian cricket captain\'s daily fitness routine',
        scheduleType: 'Celebrity',
        isActive: false,
        isPredefined: true,
        routines: [
          TemplateRoutine(
            hour: 5,
            min: 30,
            message: 'Wake up and morning walk',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 6,
            min: 0,
            message: 'Gym workout - Strength training',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 8,
            min: 0,
            message: 'Healthy breakfast (eggs, oats, fruits)',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 10,
            min: 0,
            message: 'Cricket practice session',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 13,
            min: 0,
            message: 'Lunch (grilled chicken, veggies)',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 15,
            min: 0,
            message: 'Rest and recovery',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 17,
            min: 0,
            message: 'Evening workout - Cardio',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 19,
            min: 30,
            message: 'Light dinner',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 21,
            min: 0,
            message: 'Meditation and stretching',
            isActive: true,
          ),
          TemplateRoutine(hour: 22, min: 0, message: 'Sleep', isActive: true),
        ],
        createdAt: DateTime.now(),
      ),

      // Cristiano Ronaldo's Routine
      RoutineTemplate(
        id: 'celebrity_cristiano_ronaldo',
        userId: 'system',
        name: 'Cristiano Ronaldo',
        category: 'Celebrity Routine',
        description: 'Football legend\'s training and lifestyle routine',
        scheduleType: 'Celebrity',
        isActive: false,
        isPredefined: true,
        routines: [
          TemplateRoutine(
            hour: 6,
            min: 0,
            message: 'Wake up and morning cardio',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 7,
            min: 0,
            message: 'Breakfast (whole-grain cereals, egg whites)',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 9,
            min: 0,
            message: 'Football training session 1',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 11,
            min: 30,
            message: 'Lunch (chicken, salad, beans)',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 13,
            min: 0,
            message: 'Power nap',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 15,
            min: 0,
            message: 'Gym session - Strength and conditioning',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 17,
            min: 0,
            message: 'Football training session 2',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 19,
            min: 0,
            message: 'Dinner (tuna, olives, tomatoes)',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 20,
            min: 30,
            message: 'Family time',
            isActive: true,
          ),
          TemplateRoutine(
            hour: 22,
            min: 0,
            message: 'Ice bath and recovery',
            isActive: true,
          ),
          TemplateRoutine(hour: 23, min: 0, message: 'Sleep', isActive: true),
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
