import 'package:autoroutine/features/home/presentation/home_screen.dart';
import 'package:autoroutine/features/profile/presentation/profile_screen.dart';
import 'package:autoroutine/features/routines/presentation/add_routine_screen.dart';
import 'package:autoroutine/features/routines/presentation/ai_routine_generator_screen.dart';
import 'package:autoroutine/features/routines/presentation/suggest_routine_screen.dart';
import 'package:autoroutine/features/routines/presentation/template_list_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // Start with Home (routines list)

  final List<Widget> _screens = [
    const AIRoutineGeneratorScreen(),
    const TemplateListScreen(),
    const HomeScreen(showAppBar: false),
    const SuggestRoutineScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRoutineScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.auto_awesome, 'AI', 0),
            _buildNavItem(Icons.calendar_view_week, 'Templates', 1),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(Icons.lightbulb_outline, 'Suggestions', 3),
            _buildNavItem(Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
