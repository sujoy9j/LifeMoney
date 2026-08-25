import 'package:flutter/material.dart';

import 'screens/affordability_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/goal_screen.dart';
import 'screens/retirement_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeMoneyApp());
}

class LifeMoneyApp extends StatelessWidget {
  const LifeMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeMoney',
      theme: buildLifeMoneyTheme(),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  void goTo(int destination) => setState(() => index = destination);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: goTo),
      const GoalScreen(),
      const RetirementScreen(),
      const AffordabilityScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag_rounded),
              label: 'Goals',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined),
              selectedIcon: Icon(Icons.local_fire_department_rounded),
              label: 'FIRE',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Dreams',
            ),
          ],
        ),
      ),
    );
  }
}
