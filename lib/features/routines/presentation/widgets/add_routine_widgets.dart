import 'package:autoroutine/features/routines/domain/enums.dart';
import 'package:autoroutine/features/routines/domain/add_routine_model.dart';
import 'package:flutter/material.dart';

/// Reusable card widget for step content
class StepCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const StepCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

/// Radio option card
class OptionCard<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String title;
  final String? subtitle;
  final ValueChanged<T> onChanged;

  const OptionCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Card(
        elevation: isSelected ? 4 : 0,
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<T>(
                value: value,
                groupValue: groupValue,
                onChanged: (T? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Day selector chips
class DaySelector extends StatelessWidget {
  final Set<DayOfWeek> selectedDays;
  final ValueChanged<DayOfWeek> onDayToggled;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: DayOfWeek.values.map((day) {
        final isSelected = selectedDays.contains(day);
        return FilterChip(
          label: Text(day.shortName),
          selected: isSelected,
          onSelected: (_) => onDayToggled(day),
        );
      }).toList(),
    );
  }
}

/// Time picker button
class TimePickerButton extends StatelessWidget {
  final RoutineTimeOfDay selectedTime;
  final VoidCallback onPressed;

  const TimePickerButton({
    super.key,
    required this.selectedTime,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            selectedTime.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.access_time),
          label: const Text('Pick Time'),
        ),
      ],
    );
  }
}

/// Frequency info text
class FrequencyInfo extends StatelessWidget {
  final ScheduleFrequency frequency;
  final Set<DayOfWeek> selectedDays;
  final int customFrequencyDaysPerWeek;

  const FrequencyInfo({
    super.key,
    required this.frequency,
    required this.selectedDays,
    required this.customFrequencyDaysPerWeek,
  });

  String _getInfoText() {
    switch (frequency) {
      case ScheduleFrequency.daily:
        return 'This routine will repeat every day';
      case ScheduleFrequency.specific_days:
        if (selectedDays.isEmpty) return 'Please select days';
        final days = selectedDays.map((d) => d.shortName).join(', ');
        return 'This routine will repeat on: $days';
      case ScheduleFrequency.custom_frequency:
        if (selectedDays.isEmpty) return 'Please select days';
        final days = selectedDays.map((d) => d.shortName).join(', ');
        return 'This routine will repeat $customFrequencyDaysPerWeek days per week from: $days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getInfoText(),
        style: TextStyle(color: Colors.blue.shade900),
      ),
    );
  }
}
