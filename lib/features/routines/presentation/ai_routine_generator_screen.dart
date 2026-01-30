import 'package:autoroutine/features/routines/cubit/routine_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIRoutineGeneratorScreen extends StatefulWidget {
  const AIRoutineGeneratorScreen({super.key});

  @override
  State<AIRoutineGeneratorScreen> createState() =>
      _AIRoutineGeneratorScreenState();
}

class _AIRoutineGeneratorScreenState extends State<AIRoutineGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _scheduleTypeController = TextEditingController(
    text: 'General',
  );
  final List<String> _scheduleTypes = [
    'General',
    'Home',
    'College',
    'Office',
    'Gym',
  ];
  bool _isLoading = false;
  List<Map<String, dynamic>> _generatedRoutines = [];

  @override
  void dispose() {
    _promptController.dispose();
    _scheduleTypeController.dispose();
    super.dispose();
  }

  Future<void> _generateRoutines() async {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your daily schedule'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Initialize Gemini with API key (you'll need to set this in .env)
      const apiKey = 'YOUR_GEMINI_API_KEY'; // Update with real key
      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

      final systemPrompt = '''
You are a routine scheduler assistant. Parse the user's daily schedule description and extract all tasks/routines with their times.
Return ONLY a JSON array with this format, no other text:
[
  {"time": "HH:MM", "message": "task name"},
  {"time": "HH:MM", "message": "task name"}
]
Make sure times are in 24-hour format. If no specific time is mentioned, suggest reasonable times based on the context.
''';

      final response = await model.generateContent([
        Content.multi([
          TextPart(systemPrompt),
          TextPart('User schedule: $prompt'),
        ]),
      ]);

      // Parse response
      final responseText = response.text ?? '';
      final jsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // For demo, we'll try to parse. In production, use proper JSON parsing
      try {
        // Simple parsing of JSON-like response
        final List<Map<String, dynamic>> routines = [];

        // Regex to find all {time: "...", message: "..."}
        final regex = RegExp(
          r'{\s*"time"\s*:\s*"([^"]+)"\s*,\s*"message"\s*:\s*"([^"]+)"\s*}',
        );

        for (final match in regex.allMatches(jsonString)) {
          final timeStr = match.group(1) ?? '';
          final message = match.group(2) ?? '';

          if (timeStr.isNotEmpty && message.isNotEmpty) {
            final timeParts = timeStr.split(':');
            if (timeParts.length == 2) {
              routines.add({
                'time': timeStr,
                'hour': int.tryParse(timeParts[0]) ?? 0,
                'minute': int.tryParse(timeParts[1]) ?? 0,
                'message': message,
              });
            }
          }
        }

        if (routines.isEmpty) {
          throw Exception('No routines extracted. Try a more detailed prompt.');
        }

        setState(() => _generatedRoutines = routines);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Parse error: $e'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSelectedRoutines(List<int> selectedIndices) async {
    if (selectedIndices.isEmpty) return;

    try {
      for (final idx in selectedIndices) {
        final routine = _generatedRoutines[idx];
        await context.read<RoutineCubit>().addRoutine(
          hour: routine['hour'] as int,
          minute: routine['minute'] as int,
          message: routine['message'] as String,
          scheduleType: _scheduleTypeController.text,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${selectedIndices.length} routines!'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding routines: $e'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Schedule Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Schedule Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _scheduleTypeController.text.isEmpty
                  ? null
                  : _scheduleTypeController.text,
              items: _scheduleTypes.map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _scheduleTypeController.text = value;
                  });
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select schedule type',
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Describe Your Daily Schedule',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText:
                    'E.g., "I have college from 9 AM to 5 PM with lunch at 1 PM. I need study breaks every 2 hours. Evening workout at 6 PM and dinner at 8 PM."',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateRoutines,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate Routines'),
              ),
            ),
            const SizedBox(height: 24),
            if (_generatedRoutines.isNotEmpty) ...[
              const Text(
                'Generated Routines (Select to Add)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              GeneratedRoutinesList(
                routines: _generatedRoutines,
                onAddSelected: _addSelectedRoutines,
              ),
            ] else if (!_isLoading && _promptController.text.isNotEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Click "Generate Routines" to create your schedule',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GeneratedRoutinesList extends StatefulWidget {
  final List<Map<String, dynamic>> routines;
  final Function(List<int>) onAddSelected;

  const GeneratedRoutinesList({
    super.key,
    required this.routines,
    required this.onAddSelected,
  });

  @override
  State<GeneratedRoutinesList> createState() => _GeneratedRoutinesListState();
}

class _GeneratedRoutinesListState extends State<GeneratedRoutinesList> {
  late Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = Set.from(
      List.generate(widget.routines.length, (i) => i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(widget.routines.length, (index) {
          final routine = widget.routines[index];
          final isSelected = _selectedIndices.contains(index);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIndices.add(index);
                  } else {
                    _selectedIndices.remove(index);
                  }
                });
              },
              title: Text(routine['message'] as String),
              subtitle: Text(routine['time'] as String),
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _selectedIndices.isEmpty
                ? null
                : () => widget.onAddSelected(_selectedIndices.toList()),
            child: Text('Add ${_selectedIndices.length} Routines'),
          ),
        ),
      ],
    );
  }
}
